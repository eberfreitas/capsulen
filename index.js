const elmExpress = require("elm-express");

const { Elm } = require("./build/backend");

require("dotenv").config();

const port = process.env.BACKEND_PORT || 3000;
const app = Elm.Backend.init();
const secret = process.env.BACKEND_SECRET;
const mountingRoute = "/api/";

const sessionConfig = {
  resave: false,
  saveUninitialized: true,
};

const requestCallback = (req) => {
  console.log(`[${req.method}] ${new Date().toString()} - ${req.originalUrl}`);
}

const server = elmExpress({
  app,
  secret,
  port,
  mountingRoute,
  sessionConfig,
  requestCallback
});

server.start(() => {
  console.log(`Example app listening on port ${port}`);
});
