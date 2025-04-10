import express from "express";
import adminRoutes from "./Routes/adminRoute.js";

const app = express();

dotenv.config();
console.log("ENV DEBUG:", process.env.FIREBASE_PROJECT_ID);

app.use(express.json());

app.use("/api/admin", adminRoutes);

app.get("/", (req, res) => {
  res.send("Crime Reporting System backend is up and running!");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
