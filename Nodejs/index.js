import express from "express";
import dotenv from "dotenv";
import adminRoutes from "./Routes/adminRoute.js";
import crimeRoutes from "./Routes/crimeRoute.js";

const app = express();

dotenv.config();
console.log("ENV DEBUG:", process.env.FIREBASE_PROJECT_ID);

app.use(express.json());

app.use("/api/admin", adminRoutes);
app.use("/api/crime", crimeRoutes);
app.use("/uploads", express.static("uploads"));

app.get("/", (req, res) => {
  res.send("Crime Reporting System backend is up and running!");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
