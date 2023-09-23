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
  } catch (e) {
    const error =
      e instanceof Error
        ? e.message
        : "Unexpected error while handling your registration request.";

    return { error };
  }
}
