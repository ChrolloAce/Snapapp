import SwiftUI
import FirebaseAuth

struct CommunityView: View {
    @State private var showingNewPost = false
    @State private var selectedPost: Post?
    @State private var showingRules = false
    @State private var showingChat = false
    @StateObject private var viewModel = CommunityViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    HStack {
                        Text("Community")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            // Chat Button
                            Button(action: { showingChat = true }) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.Colors.accent)
                            }
                            
                            // Rules Button
                            Button(action: { showingRules = true }) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.Colors.accent)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // Forum Content
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                    .frame(maxWidth: .infinity, minHeight: 200)
                            } else if viewModel.posts.isEmpty {
                                VStack(spacing: 16) {
                                    Text("No Posts Yet")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Be the first to share your journey!")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, minHeight: 200)
                            } else {
                                ForEach(viewModel.posts) { post in
                                    PostCard(post: post)
                                        .onTapGesture {
                                            selectedPost = post
                                        }
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        viewModel.setupPostsListener()
                    }
                }
                
                // New Post Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingNewPost = true }) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.Colors.accent)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 10)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post)
            }
            .sheet(isPresented: $showingNewPost) {
                CreatePostView()
            }
            .sheet(isPresented: $showingRules) {
                CommunityRulesView()
            }
            .fullScreenCover(isPresented: $showingChat) {
                ChatView()
            }
        }
    }
}

struct CommunityRulesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasAcceptedRules") private var hasAcceptedRules = false
    
    let rules = [
        "Do not share explicit sexual content or pornography.",
        "Avoid posting discriminatory content or hate speech.",
        "This platform is not a substitute for therapy, mental health treatment, or professional healthcare.",
        "Self-promotion, advertisements, or marketing of any kind are not allowed.",
        "Keep discussions relevant to self-improvement, particularly related to porn addiction and CSBD recovery.",
        "Respect privacy—do not collect or share personal information from members.",
        "Do not engage in disruptive behavior outside this community.",
        "Refrain from criticizing or shaming others for their personal sexual health choices. This is not an anti-masturbation space.",
        "Avoid unnecessary drama or conflicts.",
        "Discussions about politics should be avoided.",
        "Do not spread misinformation.",
        "Respect intellectual property laws—no piracy, copyright violations, or trademark infringement.",
        "Foster a positive environment by supporting and uplifting others. Avoid discouraging or demeaning comments.",
        "Be sure to review the full disclaimer and all community rules."
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Community Guidelines")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(rules.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .foregroundColor(AppTheme.Colors.accent)
                                    .font(.system(size: 16, weight: .bold))
                                
                                Text(rules[index])
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        hasAcceptedRules = true
                        dismiss()
                    }) {
                        Text("Agree to Rules")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppTheme.Colors.accent)
                            .cornerRadius(28)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RuleSection: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "161838"))
        .cornerRadius(16)
    }
}

private struct PostCard: View {
    let post: Post
    @StateObject private var viewModel = CommunityViewModel()
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showLikeAnimation = false
    @State private var isLoading = false
    @State private var showingReportAlert = false
    @State private var showingBlockAlert = false
    @State private var isBlocked = false
    
    init(post: Post) {
        self.post = post
        self._likeCount = State(initialValue: post.likes)
    }
    
    var body: some View {
        if !isBlocked {
            VStack(alignment: .leading, spacing: 12) {
                // Author Info and Menu
                HStack {
                    // Author Info
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(String(post.authorName.prefix(1)))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                            )
                        
                        Text(post.authorName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Text("• \(post.streak) Day Streak")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.Colors.accent)
                    }
                    
                    Spacer()
                    
                    // Menu Button
                    Menu {
                        Button(action: { showingReportAlert = true }) {
                            Label("Report User", systemImage: "flag")
                        }
                        
                        Button(action: { showingBlockAlert = true }) {
                            Label("Block User", systemImage: "person.fill.xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                
                // Featured Badge
                if post.isFeatured {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "FFD60A"))
                        
                        Text("Featured")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "FFD60A"))
                    }
                }
                
                // Title and Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(post.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(post.content)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .lineLimit(3)
                }
                
                // Author Info and Interactions
                HStack {
                    // Interaction Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            guard !isLoading else { return }
                            isLoading = true
                            
                            Task {
                                do {
                                    try await viewModel.likePost(post)
                                    let animation = Animation.spring(response: 0.3, dampingFraction: 0.6)
                                    withAnimation(animation) {
                                        isLiked.toggle()
                                        likeCount += isLiked ? 1 : -1
                                        showLikeAnimation = true
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        showLikeAnimation = false
                                    }
                                } catch {
                                    print("Failed to like post: \(error)")
                                }
                                isLoading = false
                            }
                        }) {
                            HStack(spacing: 8) {
                                let iconName = isLiked ? "heart.fill" : "heart"
                                let iconColor = isLiked ? Color(hex: "FF2D55") : AppTheme.Colors.accent
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: iconColor))
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: iconName)
                                        .foregroundColor(iconColor)
                                        .scaleEffect(showLikeAnimation && isLiked ? 1.2 : 1.0)
                                }
                                
                                Text("\(likeCount)")
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            Text("\(post.comments.count)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.Colors.surface.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal)
            .task {
                isLiked = await viewModel.checkIfUserLikedPost(post)
            }
            .alert("Report User", isPresented: $showingReportAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Report", role: .destructive) {
                    viewModel.reportUser(post.authorId)
                }
            } message: {
                Text("Are you sure you want to report this user? This action cannot be undone.")
            }
            .alert("Block User", isPresented: $showingBlockAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Block", role: .destructive) {
                    viewModel.blockUser(post.authorId)
                    withAnimation {
                        isBlocked = true
                    }
                }
            } message: {
                Text("Are you sure you want to block this user? You won't see their posts anymore.")
            }
        }
    }
}

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showLikeAnimation = false
    @FocusState private var isCommentFocused: Bool
    @StateObject private var viewModel = CommunityViewModel()
    @State private var isLikeLoading = false
    @State private var appeared = false
    
    init(post: Post) {
        self.post = post
        self._likeCount = State(initialValue: post.likes)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Post Content
                        VStack(alignment: .leading, spacing: 16) {
                            // Author Info
                            HStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(post.authorName.prefix(1)))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(post.authorName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    
                                    Text("\(post.streak) Day Streak")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppTheme.Colors.accent)
                                }
                                
                                Spacer()
                                
                                Text(post.timestamp, style: .relative)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            
                            // Title and Content
                            Text(post.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(post.content)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            
                            // Interaction Stats
                            HStack(spacing: 24) {
                                Button(action: {
                                    guard !isLikeLoading else { return }
                                    isLikeLoading = true
                                    
                                    Task {
                                        do {
                                            try await viewModel.likePost(post)
                                            let animation = Animation.spring(response: 0.3, dampingFraction: 0.6)
                                            withAnimation(animation) {
                                                isLiked.toggle()
                                                likeCount += isLiked ? 1 : -1
                                                showLikeAnimation = true
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                showLikeAnimation = false
                                            }
                                        } catch {
                                            print("Failed to like post: \(error)")
                                        }
                                        isLikeLoading = false
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        let iconName = isLiked ? "heart.fill" : "heart"
                                        let iconColor = isLiked ? Color(hex: "FF2D55") : AppTheme.Colors.accent
                                        
                                        if isLikeLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: iconColor))
                                                .scaleEffect(0.7)
                                        } else {
                                            Image(systemName: iconName)
                                                .foregroundColor(iconColor)
                                                .scaleEffect(showLikeAnimation && isLiked ? 1.2 : 1.0)
                                        }
                                        
                                        Text("\(likeCount)")
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "bubble.left")
                                        .foregroundColor(AppTheme.Colors.accent)
                                    Text("\(post.comments.count)")
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                            }
                            .font(.system(size: 16))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.Colors.surface.opacity(0.7))
                        )
                        
                        // Comments Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Comments")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            if post.comments.isEmpty {
                                // Empty state with Lottie animation
                                VStack(spacing: 24) {
                                    LottieView(name: "User Observation")
                                        .frame(width: 200, height: 200)
                                        .opacity(appeared ? 1 : 0)
                                        .scaleEffect(appeared ? 1 : 0.8)
                                    
                                    Text("No conversations yet")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Be the first to start the discussion")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            } else {
                                ForEach(post.comments) { comment in
                                    CommentView(comment: comment)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                
                // Comment Input Bar
                VStack {
                    Spacer()
                    CommentInputBar(text: $newComment, isFocused: _isCommentFocused, post: post)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .task {
            isLiked = await viewModel.checkIfUserLikedPost(post)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

private struct CommentInputBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    let post: Post
    @StateObject private var viewModel = CommunityViewModel()
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 12) {
                TextField("Add a comment...", text: $text)
                    .focused($isFocused)
                    .font(.system(size: 16))
                    .padding(12)
                    .background(AppTheme.Colors.surface)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .disabled(isPosting)
                
                Button(action: postComment) {
                    if isPosting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(text.isEmpty ? AppTheme.Colors.textSecondary : AppTheme.Colors.accent)
                    }
                }
                .disabled(text.isEmpty || isPosting)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.background)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func postComment() {
        guard !text.isEmpty else { return }
        isPosting = true
        
        Task {
            do {
                try await viewModel.addComment(to: post, content: text)
                text = ""
                isFocused = false
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isPosting = false
        }
    }
}

private struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(comment.authorName.prefix(1)))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                Text(comment.authorName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(comment.content)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.Colors.surface.opacity(0.5))
        )
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.surface)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
    }
} 