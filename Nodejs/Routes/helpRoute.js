import express from "express";
const router = express.Router();

router.get("/info", (req, res) => {
  const helpInfo = {
    emergencyNumbers: [
      { service: "Police", number: "100" },
      { service: "Ambulance", number: "102" },
      { service: "Fire", number: "101" },
      { service: "Women Helpline", number: "1091" },
    ],
    nearbyStations: [
      { name: "Sector 10 Police Station", address: "ABC Road, City" },
      { name: "Main City Police HQ", address: "XYZ Avenue, City" },
      { name: "Patrol Unit", address: "Near Metro Station, City" },
    ],
    tips: [
      "Stay calm while reporting.",
      "Provide accurate location.",
      "Avoid confrontation; prioritize safety.",
      "Attach evidence (photo/video) if possible.",
    ],
  };

  res.status(200).json(helpInfo);
});

export default router;
