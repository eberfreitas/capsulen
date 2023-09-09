import express from "express";
import { Client } from "pg";
import "dotenv/config";

const port = process.env.BACKEND_PORT
  ? parseInt(process.env.BACKEND_PORT, 10)
  : 3000;

const db = new Client({
  host: "localhost",
  user: "postgres",
  password: "postgres",
  database: "capsulen",
});

const server = express();

server.use(express.static("public"));

server.listen(port, async () => {
  await db.connect();
  console.log(`Example app listening on port ${port}`);
});
