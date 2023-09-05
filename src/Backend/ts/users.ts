import { App } from "elm-express";
import { Client } from "pg";
import randomstring from "randomstring";

import { existingUser, createUserRequest } from "./queries/users.queries";
import { Err, Ok } from "../../ts/result";

export type RequestAccessData = { requestId: string; username: string };

export async function handleUserAccessRequest(
  app: App,
  db: Client,
  data: RequestAccessData,
) {
  const requestId = data.requestId;
  const user = {
    username: data.username,
    nonce: `${Math.floor(Math.random() * 999999999)}`,
    challenge: randomstring.generate(),
  };

  const exists = await existingUser.run({ username: data.username }, db);

  if (exists.length > 0) {
    const data = Err<string, typeof user>(
      "Username is already in use. Please, pick a different username.",
    );
    app.ports.gotAccessRequest.send({ requestId, data });
    return;
  }

  try {
    await createUserRequest.run({ user }, db);
    app.ports.gotAccessRequest.send({
      requestId,
      data: Ok<string, typeof user>(user),
    });
  } catch (e) {
    const data = Err<string, typeof user>(
      "There was an error creating your user request. Plase, try again.",
    );
    app.ports.gotAccessRequest.send({ requestId, data });
  }
}
