/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// Simple HTTP function to test deployment
exports.helloWorld = onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

// User cleanup function
exports.cleanupUserContent = functions.auth.user().onDelete(async (user) => {
  const db = admin.firestore();
  const userId = user.uid;

  try {
    const postsSnapshot = await db.collection("posts").get();
    const batch = db.batch();

    postsSnapshot.docs.forEach((doc) => {
      const post = doc.data();
      const updatedComments = post.comments.filter(
          (comment) => comment.authorId !== userId,
      );
      batch.update(doc.ref, {comments: updatedComments});
    });

    await batch.commit();
    console.log(`Successfully cleaned up content for user ${userId}`);
    return {success: true};
  } catch (error) {
    console.error("Error cleaning up user content:", error);
    return {error: error.message};
  }
});
