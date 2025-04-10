import express from "express";
import { db } from "../firebase.js";
import multer from "multer";

const router = express.Router();

const storage = multer.diskStorage({
  destination: "uploads",
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname}`);
  },
});
const upload = multer({ storage });

router.post("/report", upload.single("media"), async (req, res) => {
  const {
    authorityType,
    officerName,
    department,
    description,
    location,
    reportedBy,
  } = req.body;

  try {
    const mediaUrl = req.file ? `/uploads/${req.file.filename}` : null;
    const report = {
      authorityType,
      officerName,
      department,
      description,
      location,
      mediaUrl,
      reportedBy,
      timestamp: new Date(),
      status: "Pending",
    };

    await db.collection("corruptionReports").add(report);
    res.status(201).json({ message: "Corruption report filed successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
