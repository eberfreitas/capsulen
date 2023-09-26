import express, { Request } from "express";
import bodyParser from "body-parser";
import { Client } from "pg";
import randomstring from "randomstring";
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

import { IGetInitialPostsResult, IGetPostsResult, createPost, getInitialPosts, getPosts } from "./db/queries/posts.queries";

const POSTS_LIMIT = 2;

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

// Prints out the key used by paseto for token crypto
// (async function () {
//   console.log(paseto.keyObjectToBytes(await getPasetoKey()).toString("base64"));
// })();

async function getAuthUser(req: Request): Promise<IGetUserResult> {
  const token = (req.headers?.["authorization"] ?? "")
    .replace("Bearer", "")
    .trim();

  const key = await getPasetoKey();
  const tokenData = await paseto.verify(token, key);

  const user: IGetUserResult[] = await getUser.run(
    { username: tokenData.sub as string },
    db,
  );

  if (user.length < 1 || !user[0]) {
    throw new Error("USER_NOT_FOUND");
  }

  return user[0];
}

const server = express();

server.use(express.static(path.join(__dirname, "public")));
server.use(bodyParser.json());
server.use(bodyParser.text());

server.listen(port, async () => {
  await db.connect();
  console.log(`Capsulen listening on port ${port}`);
});

server.post("/api/users/request_access", async (req, res) => {
  const user = {
    username: req.body,
    nonce: `${Math.floor(Math.random() * 999999999)}`,
    challenge: randomstring.generate(),
  };

  try {
    const exists = await existingUser.run({ username: user.username }, db);

    if (exists.length > 0) {
      return res
        .status(400)
        .send("USERNAME_IN_USE");
    }

    await createUserRequest.run({ user }, db);

    return res.send({
      nonce: user.nonce,
      challenge: user.challenge,
    });
  } catch (e) {
    // TODO: monitor error here...
    return res
      .status(500)
      .send("REGISTER_ERROR");
  }
});

server.post("/api/users/create_user", async (req, res) => {
  const defaultError =
    "REGISTER_ERROR";

  try {
    const possibleUser = await getPendingUser.run(
      {
        username: req.body?.username,
        nonce: req.body?.nonce,
      },
      db,
    );

    if (possibleUser.length < 1 || !possibleUser[0]) {
      return res.status(500).send(defaultError);
    }

    const user = possibleUser[0];

    await persistChallenge.run(
      {
        id: user.id,
        challengeEncrypted: req.body?.challengeEncrypted,
      },
      db,
    );

    return res.send(true);
  } catch (_) {
    // TODO: monitor error here
    return res.status(500).send(defaultError);
  }
});

server.post("/api/users/request_login", async (req, res) => {
  try {
    const possibleUser = await getUser.run({ username: req.body }, db);

    if (possibleUser.length < 1 || !possibleUser[0]) {
      return res
        .status(400)
        .send("CREDENTIALS_INCORRECT");
    }

    const user = possibleUser[0];

    res.send(user.challenge_encrypted);
  } catch (_) {
    //TODO: monitor error here
    return res
      .status(500)
      .send("LOGIN_ERROR");
  }
});

server.post("/api/users/login", async (req, res) => {
  try {
    const possibleUser = await getUser.run(
      { username: req.body?.username },
      db,
    );

    if (possibleUser.length < 1 || !possibleUser[0]) {
      return res
        .status(400)
        .send("CREDENTIALS_INCORRECT");
    }

    const user = possibleUser[0];

    if (user.challenge !== req.body?.challenge) {
      return res
        .status(400)
        .send("CREDENTIALS_INCORRECT");
    }

    const key = await getPasetoKey();
    const token = await paseto.sign({ sub: user.username }, key);

    res.send(token);
  } catch (_) {
    //TODO: monitor error here
    return res
      .status(500)
      .send("LOGIN_ERROR");
  }
});

server.post("/api/posts", async (req, res) => {
  try {
    const user = await getAuthUser(req);

    const postData = {
      user_id: user.id,
      content: req.body,
    };

    const possiblePost = await createPost.run({ post: postData }, db);

    if (possiblePost.length < 1) {
      return res
        .status(500)
        .send("POST_ERROR");
    }

    const post = possiblePost[0];

    res.send({
      id: hashids.encode(post.id),
      content: post.content,
      created_at: post.created_at,
    });
  } catch (_) {
    //TODO: monitor error here
    return res
      .status(500)
      .send("POST_ERROR");
  }
});

server.get("/api/posts", async (req, res) => {
  try {
    const user = await getAuthUser(req);
    const from = req.query?.from as string ?? null;
    let rawPosts: IGetInitialPostsResult[] | IGetPostsResult[] = [];

    if (!from) {
      rawPosts = await getInitialPosts.run(
        {
          user_id: user.id,
          limit: POSTS_LIMIT,
        },
        db,
      );
    } else {
      const id = hashids.decode(from)[0] as number ?? 0;

      rawPosts = await getPosts.run(
        {
          user_id: user.id,
          limit: POSTS_LIMIT,
          id,
        },
        db,
      );
    }

    const posts = rawPosts.map((post) => {
      return {
        id: hashids.encode(post.id),
        content: post.content,
        created_at: post.created_at,
      };
    });

    res.send(posts);
  } catch (_) {
    //TODO: monitor error here
    return res
      .status(500)
      .send("There was an error fetching your posts. Please, try again.");
  }
});

server.get("*", (_req, res) =>
  res.sendFile(path.join(__dirname, "public", "index.html")),
);
