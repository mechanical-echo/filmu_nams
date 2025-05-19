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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupAdmin = exports.makeUserAdminCallable = exports.deleteUserAccount = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
/**
 * Sets admin privileges for a specified user
 * @param {string} uid
 * @return {Object}
 */
async function makeUserAdmin(uid) {
    try {
        await admin.auth().setCustomUserClaims(uid, {
            admin: true,
        });
        console.log(`Successfully made user ${uid} an admin`);
        return {
            success: true,
        };
    }
    catch (error) {
        console.error("Error making user admin:", error);
        return {
            success: false,
            error,
        };
    }
}
const cors_1 = __importDefault(require("cors"));
const corsHandler = (0, cors_1.default)({
    origin: true,
});
exports.deleteUserAccount = functions.https.onCall(async (request) => {
    if (!request.auth || !request.auth.token.admin) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can delete users");
    }
    const uid = request.data.uid;
    try {
        await admin.auth().deleteUser(uid);
        return {
            success: true,
        };
    }
    catch (error) {
        console.error("Error deleting user:", error);
        throw new functions.https.HttpsError("internal", "Error deleting user", error instanceof Error ? error.message : String(error));
    }
});
exports.makeUserAdminCallable = functions.https.onCall(async (request) => {
    if (!request.auth || !request.auth.token.admin) {
        throw new functions.https.HttpsError("permission-denied", "Only admins can make other users admin");
    }
    return makeUserAdmin(request.data.uid);
});
exports.setupAdmin = functions.https.onCall(async (request) => {
    const result = await makeUserAdmin(request.data.uid);
    return result;
});
//# sourceMappingURL=index.js.map