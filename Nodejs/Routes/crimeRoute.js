import express from "express";
import { db } from "../firebase.js";
import multer from "multer";
import fs from "fs";

const router = express.Router();

const uploadDir = "./uploads";
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

router.post("/report", upload.single("media"), async (req, res) => {
  try {
    const { type, description, location, reportedBy, victimName } = req.body;

    if (!type || !description || !location || !reportedBy) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const mediaUrl = req.file ? `/uploads/${req.file.filename}` : null;

    const newReport = {
      type,
      description,
      location,
      reportedBy,
      mediaUrl,
      timestamp: new Date(),
      status: "Pending",
    };
    if (victimName && victimName.trim() !== "") {
      newReport.victimName = victimName.trim();
    }

    await db.collection("reports").add(newReport);
    res
      .status(201)
      .json({ message: "Crime reported successfully", report: newReport });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

export default router;
