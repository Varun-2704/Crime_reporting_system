import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import express from "express";
import { auth, db } from "../firebase.js";

const router = express.Router();

router.post("/admin/register", async (req, res) => {
  const { stationId, password, stationName, location } = req.body;

  if (!stationId || !password || !stationName || !location) {
    return res.status(400).json({ error: "All fields are required." });
  }

  try {
    const snapshot = await db
      .collection("policeAdmins")
      .where("stationId", "==", stationId)
      .get();
    if (!snapshot.empty) {
      return res
        .status(400)
        .json({ error: "Police station already registered." });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const adminDoc = await db.collection("policeAdmins").add({
      stationId,
      stationName,
      location,
      password: hashedPassword,
      createdAt: new Date(),
      role: "admin",
    });

    res
      .status(201)
      .json({ message: "Police admin registered", id: adminDoc.id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post("/admin/login", async (req, res) => {
  const { stationId, password } = req.body;

  try {
    const snapshot = await db
      .collection("policeAdmins")
      .where("stationId", "==", stationId)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ error: "Police station not found" });
    }

    const adminDoc = snapshot.docs[0];
    const adminData = adminDoc.data();

    const isMatch = await bcrypt.compare(password, adminData.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid password" });
    }

    const token = jwt.sign(
      { id: adminDoc.id, stationId: adminData.stationId, role: "admin" },
      "mySecretKey",
      { expiresIn: "2h" }
    );

    res.status(200).json({ message: "Admin login successful", token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
