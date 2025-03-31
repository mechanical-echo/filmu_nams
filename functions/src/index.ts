import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

interface DeleteUserData {
  uid: string;
}

interface MakeAdminData {
  uid: string;
}

interface SetupAdminData {
  uid: string;
}

/**
 * Sets admin privileges for a specified user
 * @param {string} uid
 * @return {Object}
 */
async function makeUserAdmin(uid: string) {
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
import cors from "cors";
const corsHandler = cors({
  origin: true,
});

export const deleteUserAccount = functions.https.onCall(
  async (request: functions.https.CallableRequest<DeleteUserData>) => {
    if (!request.auth || !request.auth.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete users"
      );
    }

    const uid = request.data.uid;

    try {
      await admin.auth().deleteUser(uid);

      return {
        success: true,
      };
    } catch (error) {
      console.error("Error deleting user:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Error deleting user",
        error instanceof Error ? error.message : String(error)
      );
    }
  }
);

export const makeUserAdminCallable = functions.https.onCall(
  async (request: functions.https.CallableRequest<MakeAdminData>) => {
    if (!request.auth || !request.auth.token.admin) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can make other users admin"
      );
    }

    return makeUserAdmin(request.data.uid);
  }
);

export const setupAdmin = functions.https.onCall(
  async (request: functions.https.CallableRequest<SetupAdminData>) => {
    const result = await makeUserAdmin(request.data.uid);
    return result;
  }
);
