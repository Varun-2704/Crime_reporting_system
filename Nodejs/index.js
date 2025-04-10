import express from "express";
import { Server } from "socket.io";
import http from "http";
import dotenv from "dotenv";
import authRoutes from "./Routes/authRoute.js";
import crimeRoutes from "./Routes/crimeRoute.js";
import adminRoutes from "./Routes/adminRoute.js";
import analyticsRoute from "./Routes/analyticsRoute.js";
import userRoute from "./Routes/userRoute.js";
import helpRoute from "./Routes/helpRoute.js";

const app = express();
const port = 5000;

dotenv.config();
console.log("ENV DEBUG:", process.env.FIREBASE_PROJECT_ID);

app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/crime", crimeRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/analytics", analyticsRoute);
app.use("/api/user", userRoute);
app.use("/api/help", helpRoute);

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});
io.on("connection", (socket) => {
  console.log("New client connected");

  const reportCollection = db.collection("reports");

  reportCollection.onSnapshot((snapshot) => {
    let reports = [];
    snapshot.forEach((doc) => reports.push({ id: doc.id, ...doc.data() }));
    socket.emit("reportsUpdated", reports);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected");
  });
});

app.get("/", (req, res) => {
  res.send("Crime Reporting System backend is up and running!");
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
