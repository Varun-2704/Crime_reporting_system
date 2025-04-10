import express from "express";
import { db } from "../firebase.js";

const router = express.Router();

router.get("/summary", async (req, res) => {
  try {
    const snapshot = await db.collection("reports").get();
    const reports = snapshot.docs.map((doc) => doc.data());

    const total = reports.length;

    const types = {};
    const statuses = {};
    const daily = {};

    reports.forEach((report) => {
      types[report.type] = (types[report.type] || 0) + 1;

      statuses[report.status] = (statuses[report.status] || 0) + 1;

      const date = new Date(report.timestamp._seconds * 1000);
      const key = `${date.getDate()}-${
        date.getMonth() + 1
      }-${date.getFullYear()}`;
      daily[key] = (daily[key] || 0) + 1;
    });

    res.status(200).json({
      totalReports: total,
      reportsByType: types,
      reportsByStatus: statuses,
      reportsPerDay: daily,
    });
  } catch (error) {
    console.error("Analytics error:", error);
    res.status(500).json({ error: "Failed to fetch analytics" });
  }
});

export default router;
