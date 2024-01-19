import { decryptData, encryptData } from "../crypto";

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
  } catch (_) {
    //TODO: monitor error
    return { error: "ENCRYPT_ERROR" };
  }
}

export async function decryptPosts(args: {
  privateKey: CryptoKey;
  posts: { id: string; content: string; created_at: string }[];
}) {
  try {
    const posts: { id: string; content: unknown; created_at: string }[] = [];

    for (let i = 0; i < args.posts.length; i++) {
      const post = args.posts[i];
      const content = JSON.parse(
        await decryptData(post.content, args.privateKey),
      );

      posts.push({ id: post.id, created_at: post.created_at, content });
    }

    return posts;
  } catch (_) {
    //TODO: monitor error
    return { error: "DECRYPT_ERROR" };
  }
}

export function deleteConfirm(args: { hashId: string; confirmText: string }) {
  const confirmed = confirm(args.confirmText);

  if (confirmed) return args.hashId;

  return null;
}
