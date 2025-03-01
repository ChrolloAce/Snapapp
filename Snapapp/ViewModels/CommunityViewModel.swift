import SwiftUI
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedFilter: PostFilter = .latest {
        didSet {
            setupPostsListener()
        }
    }
    @Published private(set) var blockedUsers: Set<String> = []
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private let authManager = AuthenticationManager.shared
    private var likesCache: [String: Int] = [:] // Cache for likes count
    private let maxRetries = 3
    
    enum PostFilter: String {
        case featured = "Featured"
        case latest = "Latest"
        case mostLiked = "Most Liked"
        case mostCommented = "Most Commented"
    }
    
    init() {
        setupPostsListener()
        loadBlockedUsers()
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user != nil {
                print("👤 User authenticated, refreshing posts")
                self?.setupPostsListener()
                self?.loadBlockedUsers()
            } else {
                print("👤 User signed out, clearing cache")
                self?.likesCache.removeAll()
                self?.blockedUsers.removeAll()
            }
        }
    }
    
    private func loadBlockedUsers() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let doc = try await db.collection("users").document(userId).getDocument()
                if let blocked = doc.data()?["blockedUsers"] as? [String] {
                    await MainActor.run {
                        blockedUsers = Set(blocked)
                    }
                }
            } catch {
                print("Failed to load blocked users: \(error)")
            }
        }
    }
    
    func blockUser(_ userId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Task {
            do {
                // Add to local blocked users
                blockedUsers.insert(userId)
                
                // Update Firestore
                try await db.collection("users").document(currentUser.uid).updateData([
                    "blockedUsers": FieldValue.arrayUnion([userId])
                ])
                
                // Remove posts from blocked user
                posts.removeAll { $0.authorId == userId }
                
                print("✅ Successfully blocked user: \(userId)")
            } catch {
                print("❌ Failed to block user: \(error)")
                // Revert local state if server update fails
                blockedUsers.remove(userId)
            }
        }
    }
    
    func reportUser(_ userId: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        Task {
            do {
                // Create report document
                try await db.collection("reports").addDocument(data: [
                    "reportedUserId": userId,
                    "reporterId": currentUser.uid,
                    "timestamp": FieldValue.serverTimestamp(),
                    "status": "pending"
                ])
                
                print("✅ Successfully reported user: \(userId)")
            } catch {
                print("❌ Failed to report user: \(error)")
            }
        }
    }
    
    private func ensureUserIsAuthenticated() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ Authentication error: No user signed in")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please sign in to continue"])
        }
        print("✅ User authenticated: \(currentUser.uid)")
    }
    
    func setupPostsListener() {
        // Remove any existing listener
        listenerRegistration?.remove()
        
        isLoading = true
        print("🔄 Setting up posts listener with filter: \(selectedFilter)")
        
        // Create base query
        var query: Query = db.collection("posts")
        
        // Filter out posts from blocked users
        if !blockedUsers.isEmpty {
            query = query.whereField("authorId", notIn: Array(blockedUsers))
        }
        
        // Configure query based on filter
        switch selectedFilter {
        case .featured:
            query = query
                .whereField("isFeatured", isEqualTo: true)
                .order(by: "timestamp", descending: true)
            print("📋 Filtering featured posts")
            
        case .latest:
            query = query.order(by: "timestamp", descending: true)
            print("📋 Showing latest posts")
            
        case .mostLiked:
            query = query
                .order(by: "likes", descending: true)
                .order(by: "timestamp", descending: true)
            print("📋 Sorting by most liked")
            
        case .mostCommented:
            query = query.order(by: "timestamp", descending: true)
            print("📋 Sorting by most commented")
        }
        
        // Limit to 20 posts at a time
        query = query.limit(to: 20)
        
        print("🔍 Executing Firestore query...")
        
        // Setup real-time listener with error handling
        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error fetching posts: \(error.localizedDescription)")
                self.error = error
                self.isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("ℹ️ No posts found")
                self.posts = []
                self.isLoading = false
                return
            }
            
            print("📄 Processing \(documents.count) posts")
            
            // Process document changes
            self.posts = documents.compactMap { document in
                do {
                    var post = try document.data(as: Post.self)
                    post.id = document.documentID
                    print("✅ Decoded post: '\(post.title)' by \(post.authorName)")
                    
                    // Update likes cache
                    if let postId = post.id {
                        self.likesCache[postId] = post.likes
                    }
                    
                    return post
                } catch {
                    print("❌ Failed to decode post: \(error)")
                    print("📝 Document data: \(document.data())")
                    return nil
                }
            }
            
            print("✅ Successfully loaded \(self.posts.count) posts")
            self.isLoading = false
        }
    }
    
    func createPost(title: String, content: String) async throws {
        try await ensureUserIsAuthenticated()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Get current user's streak
        let userDoc = try await db.collection("users").document(currentUser.uid).getDocument()
        let currentStreak = userDoc.data()?["currentStreak"] as? Int ?? 0
        
        // Create a new document reference first
        let docRef = db.collection("posts").document()
        
        // Create the post with the document ID
        let post = Post(
            id: docRef.documentID,
            authorId: currentUser.uid,
            authorName: currentUser.displayName ?? "Anonymous",
            authorEmail: currentUser.email ?? "",
            content: content,
            title: title,
            timestamp: Date(),
            likes: 0,
            comments: [],
            isFeatured: false,
            streak: currentStreak
        )
        
        do {
            // Save the post
            try await docRef.setData(from: post)
            
            // Switch to latest filter immediately after creating
            await MainActor.run {
                if self.selectedFilter != .latest {
                    self.selectedFilter = .latest
                } else {
                    self.setupPostsListener()
                }
            }
        } catch {
            print("Failed to create post: \(error)")
            throw error
        }
    }
    
    func addComment(to post: Post, content: String) async throws {
        do {
            print("💬 Attempting to add comment to post: \(post.title)")
            try await ensureUserIsAuthenticated()
            guard let currentUser = Auth.auth().currentUser else { return }
            
            guard let postId = post.id else {
                print("❌ Error: Invalid post ID")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid post ID"])
            }
            
            let comment = Comment(
                id: UUID().uuidString,
                authorId: currentUser.uid,
                authorName: currentUser.displayName ?? "Anonymous",
                content: content,
                timestamp: Date()
            )
            
            print("💬 Adding comment: \(content)")
            let docRef = db.collection("posts").document(postId)
            try await docRef.updateData([
                "comments": FieldValue.arrayUnion([try Firestore.Encoder().encode(comment)])
            ])
            print("✅ Successfully added comment")
        } catch {
            print("❌ Comment operation failed: \(error)")
            throw error
        }
    }
    
    func likePost(_ post: Post) async throws {
        do {
            print("👍 Attempting to like/unlike post: \(post.title)")
            try await ensureUserIsAuthenticated()
            guard let currentUser = Auth.auth().currentUser else { return }
            
            guard let postId = post.id else {
                print("❌ Error: Invalid post ID")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid post ID"])
            }
            
            let postRef = db.collection("posts").document(postId)
            let likeRef = postRef.collection("likes").document(currentUser.uid)
            
            var retryCount = 0
            while retryCount < maxRetries {
                do {
                    try await db.runTransaction({ (transaction, errorPointer) -> Any? in
                        do {
                            let likeDoc = try transaction.getDocument(likeRef)
                            let postDoc = try transaction.getDocument(postRef)
                            
                            let currentLikes = postDoc.data()?["likes"] as? Int ?? 0
                            
                            if likeDoc.exists {
                                print("👎 Unliking post (current likes: \(currentLikes))")
                                // Unlike
                                transaction.deleteDocument(likeRef)
                                transaction.updateData(["likes": currentLikes - 1], forDocument: postRef)
                                
                                // Update cache immediately
                                Task { @MainActor in
                                    self.likesCache[postId] = currentLikes - 1
                                }
                            } else {
                                print("👍 Liking post (current likes: \(currentLikes))")
                                // Like
                                transaction.setData([:], forDocument: likeRef)
                                transaction.updateData(["likes": currentLikes + 1], forDocument: postRef)
                                
                                // Update cache immediately
                                Task { @MainActor in
                                    self.likesCache[postId] = currentLikes + 1
                                }
                            }
                            return nil
                        } catch let fetchError as NSError {
                            errorPointer?.pointee = fetchError
                            return nil
                        }
                    })
                    
                    print("✅ Successfully updated like status")
                    break
                } catch {
                    print("❌ Error updating like status (attempt \(retryCount + 1)): \(error)")
                    retryCount += 1
                    if retryCount >= maxRetries {
                        throw error
                    }
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                }
            }
        } catch {
            print("❌ Like operation failed: \(error)")
            throw error
        }
    }
    
    func deletePost(_ post: Post) async throws {
        try await ensureUserIsAuthenticated()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard let postId = post.id else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid post ID"])
        }
        
        // Verify user owns the post
        guard post.authorId == currentUser.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "You can only delete your own posts"])
        }
        
        try await db.collection("posts").document(postId).delete()
    }
    
    func checkIfUserLikedPost(_ post: Post) async -> Bool {
        guard let currentUser = Auth.auth().currentUser,
              let postId = post.id else { return false }
        
        do {
            let likeDoc = try await db.collection("posts").document(postId).collection("likes").document(currentUser.uid).getDocument()
            return likeDoc.exists
        } catch {
            print("Error checking like status: \(error)")
            return false
        }
    }
    
    func getLikesCount(_ post: Post) -> Int {
        guard let postId = post.id else { return post.likes }
        return likesCache[postId] ?? post.likes
    }
    
    deinit {
        listenerRegistration?.remove()
    }
} 
