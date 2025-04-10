import express from "express";
import { db } from "../firebase.js";

const router = express.Router();

router.get("/history/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const snapshot = await db
      .collection("reports")
      .where("reportedBy", "==", userId)
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
