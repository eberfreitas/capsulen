import express, { Request } from "express";
import bodyParser from "body-parser";
import { Client } from "pg";
import randomstring from "randomstring";
import { Err, Ok, Result, withErr, withOk } from "shared/result";
import "dotenv/config";
import { V4 as paseto } from "paseto";
import { KeyObject } from "crypto";
import path from "path";
import Hashids from "hashids";

import {
  IGetUserResult,
  createUserRequest,
  existingUser,
  getPendingUser,
  getUser,
  persistChallenge,
} from "./db/queries/users.queries";
import { IGetInitialPostsResult, createPost, getInitialPosts } from "./db/queries/posts.queries";

const POSTS_LIMIT = 5;

const port = process.env.BACKEND_PORT
  ? parseInt(process.env.BACKEND_PORT, 10)
  : 3000;

const db = new Client({
  host: "localhost",
  user: "postgres",
  password: "postgres",
  database: "capsulen",
});

const hashids = new Hashids(process.env.PRIVATE_KEY || "", 16);

let pasetoKey: KeyObject | undefined;

async function getPasetoKey(): Promise<KeyObject> {
  if (pasetoKey) return pasetoKey;

  pasetoKey = await paseto.generateKey("public");

  return pasetoKey;
}

async function getAuthUser(
  req: Request,
): Promise<Result<IGetUserResult, string>> {
  const defaultError: Result<IGetUserResult, string> = Err(
    "You are not authorized to perform this action.",
  );

  try {
    const token = (req.headers?.["authorization"] ?? "").replace("Bearer ", "");
    const key = await getPasetoKey();
    const tokenData = await paseto.verify(token, key);
    const user: IGetUserResult[] = await getUser.run(
      { username: tokenData.sub as string },
      db,
    );

    if (user.length < 1 || !user[0]) {
      return defaultError;
    }

    return Ok(user[0]);
  } catch (_) {
    // TODO: log error and send a better error to the application
    return defaultError;
  }
}

const server = express();

server.use(express.static(path.join(__dirname, "public")));
server.use(bodyParser.json());
server.use(bodyParser.text());

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
      "There was an error registering your account. Please, try again.",
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

server.post("/api/users/login_request", async (req, res) => {
  const user = await getUser.run({ username: req.body }, db);

  if (user.length < 1 || !user[0]?.username) {
    return res.send(
      Err("Username or private key incorrect. Please, try again."),
    );
  }

  const data = user[0];

  res.send(
    Ok({
      username: data.username,
      challenge_encrypted: data.challenge_encrypted,
    }),
  );
});

server.post("/api/users/login", async (req, res) => {
  const user = await getUser.run({ username: req.body?.data?.username }, db);

  if (user.length < 1 || !user[0]) {
    return res.send(
      Err("Username or private key incorrect. Please, try again."),
    );
  }

  const data = user[0];

  if (data.challenge !== req.body?.data?.challenge) {
    return res.send(
      Err("Username or private key incorrect. Please, try again."),
    );
  }

  const key = await getPasetoKey();
  const token = await paseto.sign({ sub: data.username }, key);

  res.send(Ok(token));
});

server.post("/api/posts", async (req, res) => {
  const userResult = await getAuthUser(req);

  withOk(userResult, async (user) => {
    const postData = {
      user_id: user.id,
      content: req.body,
    };

    const possiblePost = await createPost.run({ post: postData }, db);

    if (possiblePost.length < 1) {
      return res.send(
        Err("There was an error saving your post. Please, try again."),
      );
    }

    const post = possiblePost[0];

    res.send(
      Ok({
        id: hashids.encode(post.id),
        content: post.content,
        created_at: post.created_at,
      }),
    );
  });

  withErr(userResult, (e) => res.send(Err(e)));
});

server.get("/api/posts", async (req, res) => {
  const userResult = await getAuthUser(req);

  withOk(userResult, async (user) => {
    const posts = await getInitialPosts.run({
      user_id: user.id,
      limit: POSTS_LIMIT,
    }, db);

    const finalPosts = posts.map((post) => {
      return {
        id: hashids.encode(post.id),
        content: post.content,
        created_at: post.created_at,
      };
    });

    res.send(Ok(finalPosts));
  });

  withErr(userResult, (e) => res.send(Err(e)));
});

server.get("*", (_req, res) =>
  res.sendFile(path.join(__dirname, "public", "index.html")),
);
