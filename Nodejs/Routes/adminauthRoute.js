import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import express from "express";
import { auth, db } from "../firebase.js";

const router = express.Router();

router.post("/admin/login", async (req, res) => {
  const { stationId, password } = req.body;

  if (!stationId || !password) {
    return res.status(400).json({ error: "Station ID and password required" });
  }

  try {
    const docRef = db.collection("police_stations").doc(stationId);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      return res.status(404).json({ error: "Police station not found" });
    }

    const stationData = docSnap.data();
    const isMatch = await bcrypt.compare(password, stationData.passwordHash);

    if (!isMatch) {
      return res.status(401).json({ error: "Invalid password" });
    }

    const token = jwt.sign(
      {
        id: stationId,
        stationId: stationData.stationId,
        role: "admin",
      },
      "mySecretKey", // Consider moving to env
      { expiresIn: "2h" }
    );

    res.status(200).json({ message: "Login successful", token });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

export default router;
