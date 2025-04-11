import express from "express";
import verifyToken from "../middlewares/verifyToken.js";
import { db } from "../firebase.js";

const router = express.Router();

router.get("/history", verifyToken, async (req, res) => {
  try {
    const email = req.user.email;
    console.log("req.user:", req.user);

    if (!email) {
      return res.status(400).json({ error: "Missing email in token" });
    }

    const snapshot = await db
      .collection("reports")
      .where("reportedBy", "==", email)
      .orderBy("timestamp", "desc")
      .get();

    const reports = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.status(200).json(reports);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
