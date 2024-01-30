import { decryptData, encryptData } from "../crypto";
import { captureException } from "../logger";

async function decryptPost(
  rawPost: { content: string },
  privateKey: CryptoKey,
): Promise<{ content: unknown }> {
  const post = Object.assign({}, rawPost);

  if (post.content) {
    post.content = JSON.parse(await decryptData(post.content, privateKey));
  }

  return post;
}

export async function allPosts(args: {
  userToken: string;
  privateKey: CryptoKey;
  from?: string;
}) {
  try {
    const response = await fetch(`/api/posts/all?from=${args?.from || ""}`, {
      headers: new Headers({ Authorization: `Bearer ${args.userToken}` }),
    });

    const posts = await response.json();

    for (let i = 0; i < posts.length; i++) {
      posts[i] = await decryptPost(posts[i], args.privateKey);
    }

    return posts;
  } catch (e) {
    captureException(e);

    return { error: "POST_FETCH_ERROR" };
  }
}

export async function post(args: {
  id: string;
  userToken: string;
  privateKey: CryptoKey;
}, send: (data: unknown) => void) {
  try {
    const response = await fetch(`/api/posts/${args.id}`, {
      headers: new Headers({ Authorization: `Bearer ${args.userToken}` }),
    });

    const data = await response.json();

    data["content"] = JSON.parse(await decryptData(data.content, args.privateKey));

    send(data);
  } catch(e) {
    captureException(e);

    return { error: "POST_FETCH_ERROR" };
  }
}

export async function createPost(args: {
  postContent: unknown;
  privateKey: CryptoKey;
  userToken: string;
}) {
  try {
    const content = await encryptData(
      JSON.stringify(args.postContent),
      args.privateKey,
    );

    const response = await fetch("/api/posts", {
      method: "POST",
      headers: new Headers({ Authorization: `Bearer ${args.userToken}` }),
      body: content,
    });

    const data = await response.json();

    data["content"] = args.postContent;

    return data;
  } catch (e) {
    captureException(e);

    //@TODO: right error here
    return { error: "ENCRYPT_ERROR" };
  }
}

export function deleteConfirm(args: { hashId: string; confirmText: string }) {
  const confirmed = confirm(args.confirmText);

  if (confirmed) return args.hashId;

  return null;
}
