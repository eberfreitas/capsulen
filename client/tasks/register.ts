import { encryptData, getPasswordKey } from "../crypto";

export async function encryptChallenge(args: {
  username: string;
  privateKey: string;
  challenge: string;
  nonce: string;
}) {
  try {
    const privateKey = await getPasswordKey(args.privateKey);
    const challengeEncrypted = await encryptData(args.challenge, privateKey);

    return {
      username: args.username,
      nonce: args.nonce,
      challengeEncrypted,
    };
  } catch (_) {
    //TODO: monitor error
    return { error: "UNEXPECTED_REGISTER_ERROR" };
  }
}
