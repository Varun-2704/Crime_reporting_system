import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import express from "express";
import { auth, db } from "../firebase.js";
import multer from "multer";
import fs from "fs";

const router = express.Router();

const uploadDir = "./uploads/user";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
  destination: uploadDir,
  filename: (req, file, cb) => {
    const safeName = file.originalname
      .replace(/\s+/g, "_")
      .replace(/[^a-zA-Z0-9_.]/g, "");
    cb(null, `${Date.now()}_${safeName}`);
  },
});

const upload = multer({ storage });

router.post("/register", upload.single("govtId"), async (req, res) => {
  const { email, password, name } = req.body;

  if (!email || !password || !name || !req.file) {
    return res
      .status(400)
      .json({ error: "All fields including Govt ID are required." });
  }

  try {
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: name,
    });

    const hashedPassword = await bcrypt.hash(password, 10);
    const govtIdUrl = `/uploads/${req.file.filename}`;

    await db.collection("users").doc(userRecord.uid).set({
      email,
      name,
      password: hashedPassword,
      role: "user",
      govtIdUrl,
      createdAt: new Date(),
    });

    res.status(201).json({
      message: "User registered successfully",
      uid: userRecord.uid,
      govtIdUrl,
    });
  } catch (error) {
    if (error.code === "auth/email-already-exists") {
      return res.status(400).json({ error: "Email already in use" });
    }
    res.status(500).json({ error: error.message });
  }
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const snapshot = await db
      .collection("users")
      .where("email", "==", email)
      .get();
    if (snapshot.empty)
      return res.status(404).json({ error: "User not found" });

    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();

    const isMatch = await bcrypt.compare(password, userData.password);
    if (!isMatch) return res.status(401).json({ error: "Invalid password" });

        const token = jwt.sign(
        { id: userDoc.id, email: userData.email, role: userData.role },
        "mySecretKey",
        { expiresIn: "1h" }
        );

    res.status(200).json({ message: "Login successful", token });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
