import { encryptData } from "../crypto";

export async function encryptPost(args: {
  privateKey: CryptoKey;
  postContent: { body: string };
}) {
  try {
    const content = await encryptData(
      JSON.stringify(args.postContent),
      args.privateKey,
    );

    return content;
  } catch (e) {
    const error = e instanceof Error ? e.message : "UNKNOWN_ERROR";

    return { error };
  }
}
