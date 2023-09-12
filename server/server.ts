import express from "express";
import bodyParser from "body-parser";
import { Client } from "pg";
import "dotenv/config";
import randomstring from "randomstring";

import { Err, Ok, Result } from "./src/result";
import { createUserRequest, existingUser } from "./src/queries/user.queries";

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
server.use(bodyParser.json());

server.listen(port, async () => {
  await db.connect();
  console.log(`Example app listening on port ${port}`);
});

server.post("/api/users/request_access", async (req, res) => {
  const user = {
    username: req.body?.username,
    nonce: `${Math.floor(Math.random() * 999999999)}`,
    challenge: randomstring.generate(),
  };

  const exists = await existingUser.run({ username: user.username }, db);

  let data: Result<typeof user, string> = Err("Unexpected error");

  if (exists.length > 0) {
    data = Err(
      "Username is already in use. Please, pick a different username.",
    );

    return res.send(data);
  }

  try {
    await createUserRequest.run({ user }, db);

    data = Ok(user);

    return res.send(data);
  } catch (e) {
    data = Err(
      "There was an error creating your user request. Plase, try again.",
    );

    return res.send(data);
  }
});
