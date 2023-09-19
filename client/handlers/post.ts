import { App } from "../@types/global";
import { decryptData, encryptData } from "../crypto";

export type Post = {
  id: string;
  content: string;
  created_at: string;
};

export function handlePost(
  app: App,
  getPrivateStuff: () => { token: string; privateKey: CryptoKey },
): void {
  app.ports.sendPost.subscribe(async (data) => {
    try {
      const privateStuff = getPrivateStuff();

      const content = await encryptData(
        JSON.stringify(data),
        privateStuff.privateKey,
      );

      const response = await fetch("/api/posts", {
        method: "POST",
        body: content,
        headers: new Headers({
          "content-type": "text/plain",
          authorization: `Bearer ${privateStuff.token}`,
        }),
      });

      const raw = await response.text();
      const post = JSON.parse(raw);
      const decryptedContent = await decryptData(
        post.content,
        privateStuff.privateKey,
      );

      const finalPost = {
        ...post,
        content: JSON.parse(decryptedContent),
      };

      app.ports.getPost.send(finalPost);
    } catch(e) {
      // TODO: log error to monitoring app
      app.ports.getError.send("There was a problem dealing with your post. Please, try again.");
    }
  });
}
