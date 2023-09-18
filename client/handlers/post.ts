import { Ok, Result } from "shared/result";
import { App } from "../@types/global";
import { decryptData, encryptData } from "../crypto";

type Post = {
  id: string;
  content: string;
  created_at: string;
};

export function handlePost(
  app: App,
  getPrivateStuff: () => { token: string; privateKey: CryptoKey } | null,
): void {
  app.ports.sendPost.subscribe(async (data) => {
    const privateStuff = getPrivateStuff();

    if (!privateStuff) return;

    const contentResult = await encryptData(
      JSON.stringify(data),
      privateStuff.privateKey,
    );

    if (contentResult._kind === "err") {
      return app.ports.getPost.send(contentResult);
    }

    const content = contentResult.data;

    const response = await fetch("/api/posts", {
      method: "POST",
      body: content,
      headers: new Headers({
        "content-type": "text/plain",
        authorization: `Bearer ${privateStuff.token}`,
      }),
    });

    const raw = await response.text();
    const postResult = JSON.parse(raw) as Result<Post, string>;

    if (postResult._kind === "err") {
      return app.ports.getPost.send(postResult);
    }

    const post = postResult.data;
    const decryptedContent = await decryptData(
      post.content,
      privateStuff.privateKey,
    );

    if (decryptedContent._kind === "err") {
      return app.ports.getPost.send(decryptedContent);
    }

    const postContent = decryptedContent.data;

    const finalPost = {
      ...post,
      content: JSON.parse(postContent),
    };

    return app.ports.getPost.send(Ok(finalPost));
  });
}
