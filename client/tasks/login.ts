import { decryptData, getPasswordKey } from "../crypto";

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
  } catch (_) {
    // TODO: monitor error
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
      token: args.token
    };
  } catch(e) {
    const error =
      e instanceof Error
        ? e.message
        : "LOGIN_ERROR";

    return { error };
  }
}
