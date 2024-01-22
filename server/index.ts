import express, { Request } from "express";
import bodyParser from "body-parser";
import { Client } from "pg";
import randomstring from "randomstring";
import "dotenv/config";
import { V4 as paseto } from "paseto";
import { KeyObject } from "crypto";
import path from "path";
import Hashids from "hashids";
import * as Sentry from "@sentry/node";
import { ProfilingIntegration } from "@sentry/profiling-node";

import {
  IGetUserResult,
  createUserRequest,
  existingUser,
  getPendingUser,
  getUser,
  persistChallenge,
} from "./db/queries/users.queries";

import {
  IGetInitialPostsResult,
  IGetPostsResult,
  createPost,
  deletePost,
  getInitialPosts,
  getPosts,
} from "./db/queries/posts.queries";

const POSTS_LIMIT = 10;

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

  const existingKey = process.env.PASETO_KEY;

  if (existingKey) {
    pasetoKey = paseto.bytesToKeyObject(Buffer.from(existingKey, "base64"));
  } else {
    pasetoKey = await paseto.generateKey("public");

    console.warn(
      `Env var PASETO_KEY not set. Starting with a generated key:\n${paseto
        .keyObjectToBytes(pasetoKey)
        .toString("base64")}`,
    );
  }

  return pasetoKey;
}

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

let captureException = console.error;

if (process.env.SENTRY_SERVER_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_SERVER_DSN,
    integrations: [
      new Sentry.Integrations.Http({ tracing: true }),
      new Sentry.Integrations.Express({ app: server }),
      new ProfilingIntegration(),
    ],
    tracesSampleRate: 1.0,
    profilesSampleRate: 1.0,
  });

  server.use(Sentry.Handlers.requestHandler());
  server.use(Sentry.Handlers.tracingHandler());

  captureException = Sentry.captureException;
}

server.use(express.static(path.join(__dirname, "public")));
server.use(bodyParser.json({ limit: "10mb" }));
server.use(bodyParser.text({ limit: "10mb" }));

server.post("/api/users/request_access", async (req, res) => {
  const user = {
    username: req.body,
    nonce: `${Math.floor(Math.random() * 999999999)}`,
    challenge: randomstring.generate(),
  };

  try {
    const exists = await existingUser.run({ username: user.username }, db);

    if (exists.length > 0) {
      return res.status(400).send("USERNAME_IN_USE");
    }

    await createUserRequest.run({ user }, db);

    return res.send({
      nonce: user.nonce,
      challenge: user.challenge,
    });
  } catch (e) {
    captureException(e);

    return res.status(500).send("REGISTER_ERROR");
  }
});

server.post("/api/users/create_user", async (req, res) => {
  const defaultError = "REGISTER_ERROR";

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
  } catch (e) {
    captureException(e);

    return res.status(500).send(defaultError);
  }
});

server.post("/api/users/request_login", async (req, res) => {
  try {
    const possibleUser = await getUser.run({ username: req.body }, db);

    if (possibleUser.length < 1 || !possibleUser[0]) {
      return res.status(400).send("CREDENTIALS_INCORRECT");
    }

    const user = possibleUser[0];

    res.send(user.challenge_encrypted);
  } catch (e) {
    captureException(e);

    return res.status(500).send("LOGIN_ERROR");
  }
});

server.post("/api/users/login", async (req, res) => {
  try {
    const possibleUser = await getUser.run(
      { username: req.body?.username },
      db,
    );

    if (possibleUser.length < 1 || !possibleUser[0]) {
      return res.status(400).send("CREDENTIALS_INCORRECT");
    }

    const user = possibleUser[0];

    if (user.challenge !== req.body?.challenge) {
      return res.status(400).send("CREDENTIALS_INCORRECT");
    }

    const key = await getPasetoKey();
    const token = await paseto.sign({ sub: user.username }, key);

    res.send(token);
  } catch (e) {
    captureException(e);

    return res.status(500).send("LOGIN_ERROR");
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
      return res.status(500).send("POST_ERROR");
    }

    const post = possiblePost[0];

    res.send({
      id: hashids.encode(post.id),
      content: post.content,
      created_at: post.created_at,
    });
  } catch (e) {
    captureException(e);

    return res.status(500).send("POST_ERROR");
  }
});

server.get("/api/posts", async (req, res) => {
  try {
    const user = await getAuthUser(req);
    const from = (req.query?.from as string) ?? null;
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
      const id = (hashids.decode(from)?.[0] as number) ?? 0;

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
  } catch (e) {
    captureException(e);

    return res.status(500).send("POST_FETCH_ERROR");
  }
});

server.post("/api/posts/:id", async (req, res) => {
  try {
    const user = await getAuthUser(req);
    const rawPostId = req.params?.id || "";
    const id = (hashids.decode(rawPostId)?.[0] as number) || null;

    id && (await deletePost.run({ user_id: user.id, id: id }, db));
  } catch (_) {
    // We don't really care if something goes wrong here...
  }

  res.send(true);
});

server.get("*", (_req, res) =>
  res.sendFile(path.join(__dirname, "public", "index.html")),
);

if (process.env.SENTRY_SERVER_DSN) {
  server.use(Sentry.Handlers.errorHandler());
}

server.listen(port, async () => {
  await db.connect();
  console.log(`Capsulen listening on port ${port}`);
});
