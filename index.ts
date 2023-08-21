import express, { Request } from "express";
import { elmExpress } from "elm-express";
import "dotenv/config";

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

server.start(() => {
  console.log(`Example app listening on port ${port}`);
});
