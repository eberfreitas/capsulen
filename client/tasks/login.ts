import { decryptData, getPasswordKey } from "../crypto";
import { captureException } from "../logger";

export async function decryptChallenge(args: {
  username: string;
  privateKey: string;
  challengeEncrypted: string;
}) {
  try {
    const privateKey = await getPasswordKey(args.privateKey);
    const challenge = await decryptData(args.challengeEncrypted, privateKey);

    return {
      username: args.username,
      challenge,
    };
  } catch (e) {
    captureException(e);

    return { error: "CREDENTIALS_INCORRECT" };
  }
}

export async function buildUser(args: {
  username: string;
  privateKey: string;
  token: string;
}) {
  try {
    const privateKey = await getPasswordKey(args.privateKey);

    return {
      username: args.username,
      privateKey: privateKey,
      token: args.token,
    };
  } catch (e) {
    captureException(e);

    return { error: "LOGIN_ERROR" };
  }
}
