import express from "express";
import bodyParser from "body-parser";
import { Client } from "pg";
import randomstring from "randomstring";
import { Err, Ok, Result } from "shared/result";
import "dotenv/config";

import {
  createUserRequest,
  existingUser,
  getPendingUser,
  persistChallenge,
} from "./db/queries/users.queries";

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
  } catch (_) {
    data = Err(
      "There was an error creating your user request. Please, try again.",
    );

    return res.send(data);
  }
});

server.post("/api/users/create_user", async (req, res) => {
  const user = await getPendingUser.run(
    {
      username: req.body?.data?.username,
      nonce: req.body?.data?.nonce,
    },
    db,
  );

  const defaultError = Err(
    "There was an error registering your account. Please, try again.",
  );

  if (user.length < 1 || !user[0]?.id) {
    return res.send(defaultError);
  }

  try {
    persistChallenge.run(
      {
        id: user[0].id,
        challengeEncrypted: req.body?.data?.challengeEncrypted,
      },
      db,
    );
  } catch (_) {
    return res.send(defaultError);
  }

  res.send(Ok(true));
});
