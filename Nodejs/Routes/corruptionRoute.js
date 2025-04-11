import express from "express";
import { db } from "../firebase.js";
import multer from "multer";
import transporter from "../utils/emailService.js";

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

    const emailBody = `
      🚨 New Corruption Report 🚨

      Authority Type: ${authorityType}
      Officer Name: ${officerName}
      Department: ${department}
      Location: ${location}
      Description:
      ${description}

      Reported By: ${reportedBy || "Anonymous"}
      Timestamp: ${new Date().toLocaleString()}
      Media: ${mediaUrl ? `Attached: ${mediaUrl}` : "No media attached"}
    `;

    await transporter.sendMail({
      from: process.env.MAIL_USER,
      to: "vaibhavsatone252@gmail.com",
      subject: "New Corruption Complaint ",
      text: emailBody,
    });

    res.status(201).json({ message: "Corruption report filed successfully." });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
