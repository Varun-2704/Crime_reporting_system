import admin from "firebase-admin";
import fs from "fs";
import bcrypt from "bcryptjs";

import dotenv from "dotenv";

dotenv.config({ path: "../.env" });

const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY
    ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n")
    : undefined,
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL,
};

console.log("DEBUG FIREBASE CONFIG:", {
  project_id: typeof serviceAccount.project_id,
  private_key_id: typeof serviceAccount.private_key_id,
  private_key: typeof serviceAccount.private_key,
  client_email: typeof serviceAccount.client_email,
  client_id: typeof serviceAccount.client_id,
  client_x509_cert_url: typeof serviceAccount.client_x509_cert_url,
  hasPrivateKeyNewline: serviceAccount.private_key?.includes("\n"),
});

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

const stationData = JSON.parse(
  fs.readFileSync("./police_stations_india.json", "utf-8")
);

async function uploadStations() {
  const batch = db.batch();

  const defaultPassword = "station123";
  const passwordHash = await bcrypt.hash(defaultPassword, 10);

  stationData.forEach((station) => {
    const docRef = db.collection("police_stations").doc(station.stationId);
    station.passwordHash = passwordHash; // Set hashed password
    batch.set(docRef, station);
  });
  try {
    await batch.commit();
    console.log("✅ All police stations uploaded to Firestore.");
  } catch (error) {
    console.error("❌ Upload failed:", error);
  }
}

uploadStations();
