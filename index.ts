import express, { Request } from "express";
import { elmExpress } from "elm-express";
import { Client } from "pg";
import "dotenv/config";

import {
  RequestAccessData,
  handleUserAccessRequest,
} from "./src/Backend/ts/users";

// This just avoids a bunch of problems with module loading and TS
// eslint-disable-next-line
const { Elm } = require("./build/backend");

const port = process.env.BACKEND_PORT
  ? parseInt(process.env.BACKEND_PORT, 10)
  : 3000;

const app = Elm.Backend.init();
const secret = process.env.BACKEND_SECRET || "f4k3s3cr3t";
const mountingRoute = "/api/";
const timeout = 5000;

const sessionConfig = {
  resave: false,
  saveUninitialized: true,
};

const requestCallback = (req: Request): void => {
  console.log(`[${req.method}] ${new Date().toString()} - ${req.originalUrl}`);
};

const db = new Client({
  host: "localhost",
  user: "postgres",
  password: "postgres",
  database: "capsulen",
});

const server = elmExpress({
  app,
  secret,
  port,
  mountingRoute,
  sessionConfig,
  requestCallback,
  timeout,
});

server.use(express.static("public"));

server.start(async () => {
  await db.connect();
  console.log(`Example app listening on port ${port}`);
});

app.ports.userRequestAccess.subscribe((data: RequestAccessData) =>
  handleUserAccessRequest(app, db, data),
);
