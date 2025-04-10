import express from "express";
import { db } from "../firebase.js";
import { FieldValue } from "firebase-admin/firestore";

const router = express.Router();

router.get("/reports", async (req, res) => {
  try {
    const snapshot = await db.collection("reports").get();
    const reports = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    res.status(200).json(reports);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.patch("/report/:id/status", async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    await db.collection("reports").doc(id).update({ status });
    res.status(200).json({ message: "Status updated" });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.delete("/report/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await db.collection("reports").doc(id).delete();
    res.status(200).json({ message: "Report deleted" });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.post("/update-report/:id", async (req, res) => {
  const { message } = req.body;
  const reportId = req.params.id;

  try {
    const reportRef = db.collection("reports").doc(reportId);

    await reportRef.update({
      updates: FieldValue.arrayUnion({
        message,
        timestamp: new Date().toISOString(),
      }),
    });

    res.status(200).json({ success: true, message: "Update added" });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
});

router.get("/grouped-reports", async (req, res) => {
  try {
    const snapshot = await db.collection("reports").get();
    const reports = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    const groupedReports = {};
    reports.forEach((report) => {
      const user = report.reportedBy || "Anonymous";
      if (!groupedReports[user]) {
        groupedReports[user] = [];
      }
      groupedReports[user].push(report);
    });

    res.status(200).json(groupedReports);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


router.get("/timeline/public", async (req, res) => {
  try {
    const snapshot = await db.collection("reports").orderBy("timestamp", "desc").limit(50).get();
    
    const feed = snapshot.docs.map((doc) => {
      const data = doc.data();
      const time = new Date(data.timestamp).toLocaleTimeString("en-IN", { hour: '2-digit', minute: '2-digit' });
      let message = "";

      if (data.status === "Resolved") {
        message = `✅ ${data.type} resolved at ${data.location} at ${time}`;
      } else {
        message = `🚨 ${data.type} reported near ${data.location} at ${time}`;
      }

      return {
        id: doc.id,
        message,
        rawData: data,
      };
    });

    res.status(200).json(feed);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


export default router;
