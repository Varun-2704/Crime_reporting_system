import express from "express";
import { auth } from "../firebase.js";

const router = express.Router();

router.post("/register", async (req, res) => {
  const { email, password, displayName } = req.body;
  try {
    const user = await auth.createUser({ email, password, displayName });
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.post("/login", async (req, res) => {
  res.status(200).json({ message: "Use Firebase SDK to log in" });
});

export default router;
