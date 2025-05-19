"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.finalizeProfileImageUpload = exports.getProfileImageUploadUrl = exports.getAllUsers = exports.getUserById = exports.deleteUser = exports.updateUser = exports.createUser = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
// Ensure admin is initialized
if (!admin.apps.length) {
    admin.initializeApp();
}
const firestore = admin.firestore();
const auth = admin.auth();
const storage = admin.storage().bucket();
/**
 * Create a new user with the provided data
 */
exports.createUser = functions.https.onCall(async (data, context) => {
    var _a;
    // Check if requester is an admin
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can create users");
    }
    try {
        // Create user in Firebase Auth
        const userRecord = await auth.createUser({
            email: data.email,
            password: data.password,
            displayName: data.name,
            photoURL: data.profileImageUrl || "",
        });
        // Create user document in Firestore
        await firestore
            .collection("users")
            .doc(userRecord.uid)
            .set({
            name: data.name,
            email: data.email,
            profileImageUrl: data.profileImageUrl || "",
            role: data.role,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return {
            success: true,
            uid: userRecord.uid,
        };
    }
    catch (error) {
        console.error("Error creating user:", error);
        throw new functions.https.HttpsError("internal", "Error creating user", error instanceof Error ? error.message : String(error));
    }
});
/**
 * Update an existing user
 */
exports.updateUser = functions.https.onCall(async (data, context) => {
    var _a, _b, _c;
    // Check if requester is an admin or the user themselves
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin) && ((_b = context.auth) === null || _b === void 0 ? void 0 : _b.uid) !== data.uid) {
        throw new functions.https.HttpsError("permission-denied", "You don't have permission to update this user");
    }
    // Prevent non-admins from changing roles
    if (!((_c = context.auth) === null || _c === void 0 ? void 0 : _c.token.admin) && data.role) {
        const userDoc = await firestore.collection("users").doc(data.uid).get();
        const userData = userDoc.data();
        if (userData && userData.role !== data.role) {
            throw new functions.https.HttpsError("permission-denied", "Only admins can change user roles");
        }
    }
    try {
        // Update auth record
        const updateAuthData = {
            displayName: data.name,
            email: data.email,
        };
        if (data.profileImageUrl) {
            updateAuthData.photoURL = data.profileImageUrl;
        }
        else if (data.deleteImage) {
            updateAuthData.photoURL = "";
        }
        await auth.updateUser(data.uid, updateAuthData);
        // Update Firestore document
        const updateData = {
            name: data.name,
            email: data.email,
            role: data.role,
        };
        if (data.profileImageUrl) {
            updateData.profileImageUrl = data.profileImageUrl;
        }
        else if (data.deleteImage) {
            updateData.profileImageUrl = "";
            // Try to delete the image from storage
            try {
                await storage.file(`profile_images/${data.uid}.jpg`).delete();
            }
            catch (e) {
                console.log("Image may not exist, continuing:", e);
            }
        }
        await firestore.collection("users").doc(data.uid).update(updateData);
        return { success: true };
    }
    catch (error) {
        console.error("Error updating user:", error);
        throw new functions.https.HttpsError("internal", "Error updating user", error instanceof Error ? error.message : String(error));
    }
});
/**
 * Delete a user
 */
exports.deleteUser = functions.https.onCall(async (data, context) => {
    var _a;
    // Check if requester is an admin
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can delete users");
    }
    try {
        // Delete the user's profile image if it exists
        try {
            await storage.file(`profile_images/${data.uid}.jpg`).delete();
        }
        catch (e) {
            console.log("Image may not exist, continuing:", e);
        }
        // Delete user from Firestore
        await firestore.collection("users").doc(data.uid).delete();
        // Delete user from Auth
        await auth.deleteUser(data.uid);
        return { success: true };
    }
    catch (error) {
        console.error("Error deleting user:", error);
        throw new functions.https.HttpsError("internal", "Error deleting user", error instanceof Error ? error.message : String(error));
    }
});
/**
 * Get a user by ID
 */
exports.getUserById = functions.https.onCall(async (data, context) => {
    var _a;
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    // Regular users can only get their own data
    if (!context.auth.token.admin && context.auth.uid !== data.uid) {
        throw new functions.https.HttpsError("permission-denied", "You don't have permission to access this user's data");
    }
    try {
        const userDoc = await firestore.collection("users").doc(data.uid).get();
        if (!userDoc.exists) {
            throw new functions.https.HttpsError("not-found", "User not found");
        }
        const userData = userDoc.data();
        return {
            id: userDoc.id,
            ...userData,
            createdAt: (_a = userData === null || userData === void 0 ? void 0 : userData.createdAt) === null || _a === void 0 ? void 0 : _a.toDate().toISOString(),
        };
    }
    catch (error) {
        console.error("Error getting user:", error);
        throw new functions.https.HttpsError("internal", "Error getting user", error instanceof Error ? error.message : String(error));
    }
});
/**
 * Get all users (admin only)
 */
exports.getAllUsers = functions.https.onCall(async (data, context) => {
    var _a;
    // Check if requester is an admin
    if (!((_a = context.auth) === null || _a === void 0 ? void 0 : _a.token.admin)) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can list all users");
    }
    try {
        const querySnapshot = await firestore.collection("users").get();
        const users = querySnapshot.docs.map((doc) => {
            var _a;
            const data = doc.data();
            return {
                id: doc.id,
                ...data,
                createdAt: (_a = data.createdAt) === null || _a === void 0 ? void 0 : _a.toDate().toISOString(),
            };
        });
        return { users };
    }
    catch (error) {
        console.error("Error listing users:", error);
        throw new functions.https.HttpsError("internal", "Error listing users", error instanceof Error ? error.message : String(error));
    }
});
/**
 * Generate a signed URL for profile image upload
 */
exports.getProfileImageUploadUrl = functions.https.onCall(async (data, context) => {
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    // Regular users can only get upload URLs for themselves
    if (!context.auth.token.admin && context.auth.uid !== data.uid) {
        throw new functions.https.HttpsError("permission-denied", "You don't have permission to upload for this user");
    }
    try {
        const filePath = `profile_images/${data.uid}.jpg`;
        const file = storage.file(filePath);
        // Generate a signed URL for uploading
        const [url] = await file.getSignedUrl({
            version: "v4",
            action: "write",
            expires: Date.now() + 15 * 60 * 1000,
            contentType: data.contentType,
        });
        return { url, filePath };
    }
    catch (error) {
        console.error("Error generating upload URL:", error);
        throw new functions.https.HttpsError("internal", "Error generating upload URL", error instanceof Error ? error.message : String(error));
    }
});
/**
 * Finish profile image upload process
 */
exports.finalizeProfileImageUpload = functions.https.onCall(async (data, context) => {
    // Check authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    // Regular users can only finalize uploads for themselves
    if (!context.auth.token.admin && context.auth.uid !== data.uid) {
        throw new functions.https.HttpsError("permission-denied", "You don't have permission for this user");
    }
    try {
        const file = storage.file(data.filePath);
        const [metadata] = await file.getMetadata();
        // Generate a public URL for the file
        const publicUrl = `https://storage.googleapis.com/${storage.name}/${data.filePath}`;
        // Update user document and auth profile
        await firestore.collection("users").doc(data.uid).update({
            profileImageUrl: publicUrl,
        });
        await auth.updateUser(data.uid, {
            photoURL: publicUrl,
        });
        return { success: true, url: publicUrl };
    }
    catch (error) {
        console.error("Error finalizing image upload:", error);
        throw new functions.https.HttpsError("internal", "Error finalizing image upload", error instanceof Error ? error.message : String(error));
    }
});
//# sourceMappingURL=users.js.map