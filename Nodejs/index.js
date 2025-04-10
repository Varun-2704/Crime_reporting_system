import express from "express";
import dotenv from "dotenv";
import adminRoutes from "./Routes/adminRoute.js";
import crimeRoutes from "./Routes/crimeRoute.js";
import analyticsRoute from "./Routes/analyticsRoute.js";
import corruptionRoute from "./Routes/corruptionRoute.js";
import authRoute from "./Routes/authRoute.js";
import adminauthRoute from "./Routes/adminauthRoute.js";
import userRoute from "./Routes/userRoute.js";

const app = express();

dotenv.config();
console.log("ENV DEBUG:", process.env.FIREBASE_PROJECT_ID);

app.use(express.json());

app.use("/api/admin", adminRoutes);
app.use("/api/crime", crimeRoutes);
app.use("/uploads", express.static("uploads"));
app.use("/api/analytics", analyticsRoute);
app.use("/api/corruption", corruptionRoute);
app.use("/api/auth", authRoute);
app.use("/api/adminauth", adminauthRoute);
app.use("/api/user", userRoute);

app.get("/", (req, res) => {
  res.send("Crime Reporting System backend is up and running!");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
