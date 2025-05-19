const functions = require("firebase-functions");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const firestore = admin.firestore();
const auth = admin.auth();
const storage = admin.storage().bucket();

firestore.settings({ ignoreUndefinedProperties: true });

const verifyUserPermissions = async (uid) => {
  if (!uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  try {
    const userRecord = await admin.auth().getUser(uid);
    const customClaims = userRecord.customClaims || {};

    const hasPermission = customClaims.admin;

    if (!hasPermission) {
      throw new functions.https.HttpsError(
        "permission-denied",
        `A user is not an admin`
      );
    }

    return true;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    console.error("Error verifying permissions:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error verifying user permissions",
      error instanceof Error ? error.message : String(error)
    );
  }
};

exports.createUser = functions.https.onCall(async (req, context) => {
  await verifyUserPermissions(req.data.currentUid);

  try {
    const userRecord = await auth.createUser(
      req.data.profileImageUrl
        ? {
            email: req.data.email,
            password: req.data.password,
            displayName: req.data.name,
            photoURL: req.data.profileImageUrl,
          }
        : {
            email: req.data.email,
            password: req.data.password,
            displayName: req.data.name,
          }
    );

    await firestore
      .collection("users")
      .doc(userRecord.uid)
      .set({
        name: req.data.name,
        email: req.data.email,
        profileImageUrl: req.data.profileImageUrl || "",
        role: req.data.role,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return {
      success: true,
      uid: userRecord.uid,
    };
  } catch (error) {
    console.error("Error creating user:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error creating user",
      error instanceof Error ? error.message : String(error)
    );
  }
});

exports.updateUser = functions.https.onCall(async (req, context) => {
  await verifyUserPermissions(req.data.currentUid);
  try {
    const data = req.data;

    const updateAuthData = {
      displayName: data.name,
      email: data.email,
    };

    if (data.profileImageUrl) {
      updateAuthData.photoURL = data.profileImageUrl;
    } else if (data.deleteImage) {
      updateAuthData.photoURL = "";
    }

    await auth.updateUser(data.uid, updateAuthData);

    const updateData = {
      name: data.name,
      email: data.email,
      role: data.role,
    };

    if (data.profileImageUrl) {
      updateData.profileImageUrl = data.profileImageUrl;
    } else if (data.deleteImage) {
      updateData.profileImageUrl = "";
      try {
        await storage.file(`profile_images/${data.uid}.jpg`).delete();
      } catch (e) {
        console.log("Image may not exist, continuing:", e);
      }
    }

    await firestore.collection("users").doc(data.uid).update(updateData);

    return { success: true };
  } catch (error) {
    console.error("Error updating user:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error updating user",
      error instanceof Error ? error.message : String(error)
    );
  }
});

exports.deleteUser = functions.https.onCall(async (req, context) => {
  await verifyUserPermissions(req.data.currentUid);
  try {
    try {
      await storage.file(`profile_images/${req.data.uid}.jpg`).delete();
    } catch (e) {
      console.log("Image may not exist, continuing:", e);
    }

    await firestore.collection("users").doc(req.data.uid).delete();

    await auth.deleteUser(req.data.uid);

    return { success: true };
  } catch (error) {
    console.error("Error deleting user:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error deleting user",
      error instanceof Error ? error.message : String(error)
    );
  }
});

exports.getUserById = functions.https.onCall(async (req, context) => {
  await verifyUserPermissions(req.data.currentUid);
  try {
    const userDoc = await firestore.collection("users").doc(req.data.uid).get();

    if (!userDoc.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const userData = userDoc.data();

    return {
      id: userDoc.id,
      name: userData.name || "",
      email: userData.email || "",
      profileImageUrl: userData.profileImageUrl || "",
      role: userData.role || "user",
      createdAt: userData.createdAt
        ? userData.createdAt.toDate().toISOString()
        : new Date().toISOString(),
    };
  } catch (error) {
    console.error("Error getting user:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error getting user",
      error instanceof Error ? error.message : String(error)
    );
  }
});

exports.getAllUsers = functions.https.onCall(async (req, context) => {
  await verifyUserPermissions(req.data.currentUid);
  try {
    const querySnapshot = await firestore.collection("users").get();

    const users = querySnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate().toISOString(),
      };
    });

    return { users };
  } catch (error) {
    console.error("Error listing users:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error listing users",
      error instanceof Error ? error.message : String(error)
    );
  }
});

exports.getProfileImageUploadUrl = functions.https.onCall(
  async (req, context) => {
    try {
      const data = req.data;
      const filePath = `profile_images/${data.uid}.jpg`;
      const file = storage.file(filePath);

      const [url] = await file.getSignedUrl({
        version: "v4",
        action: "write",
        expires: Date.now() + 15 * 60 * 1000,
        contentType: data.contentType,
      });

      return { url, filePath };
    } catch (error) {
      console.error("Error generating upload URL:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error generating upload URL",
        error instanceof Error ? error.message : String(error)
      );
    }
  }
);

exports.finalizeProfileImageUpload = functions.https.onCall(
  async (req, context) => {
    try {
      const data = req.data;
      const file = storage.file(data.filePath);
      const [metadata] = await file.getMetadata();

      const publicUrl = `https://storage.googleapis.com/${storage.name}/${data.filePath}`;

      await firestore.collection("users").doc(data.uid).update({
        profileImageUrl: publicUrl,
      });

      await auth.updateUser(data.uid, {
        photoURL: publicUrl,
      });

      return { success: true, url: publicUrl };
    } catch (error) {
      console.error("Error finalizing image upload:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error finalizing image upload",
        error instanceof Error ? error.message : String(error)
      );
    }
  }
);
