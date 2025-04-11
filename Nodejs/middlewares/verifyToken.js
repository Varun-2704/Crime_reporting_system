import jwt from "jsonwebtoken";

const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized: No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, "mySecretKey");
    req.user = decoded;
    next();
    console.log("Decoded token:", decoded);
    console.log("Decoded token payload:", req.user);
  } catch (error) {
    res.status(401).json({ error: "Invalid or expired token" });
  }
};

export default verifyToken;
