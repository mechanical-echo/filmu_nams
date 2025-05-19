const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

if (!admin.apps.length) {
  admin.initializeApp();
}

async function makeUserAdmin(uid) {
  try {
    await admin.auth().setCustomUserClaims(uid, {
      admin: true,
    });
    console.log(`Successfully made user ${uid} an admin`);

    return {
      success: true,
    };
  } catch (error) {
    console.error("Error making user admin:", error);
    return {
      success: false,
      error,
    };
  }
}

const userFunctions = require("./users");

exports.setupAdmin = functions.https.onCall(async (data, context) => {
  const result = await makeUserAdmin(data.uid);
  return result;
});

exports.createUser = userFunctions.createUser;
exports.updateUser = userFunctions.updateUser;
exports.deleteUser = userFunctions.deleteUser;
exports.getUserById = userFunctions.getUserById;
exports.getAllUsers = userFunctions.getAllUsers;
exports.getProfileImageUploadUrl = userFunctions.getProfileImageUploadUrl;
exports.finalizeProfileImageUpload = userFunctions.finalizeProfileImageUpload;
