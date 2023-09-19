import { Err, Ok, Result, withDefault } from "shared/result";
import { App } from "../@types/global";
import { Post } from "./post";
import { decryptData } from "../crypto";

export function handlePosts(
  app: App,
  getPrivateStuff: () => { token: string; privateKey: CryptoKey } | null,
) {
  app.ports.sendPostsRequest.subscribe(async () => {
    const privateStuff = getPrivateStuff();

    if (!privateStuff) return;

    const headers = new Headers({
      authorization: `Bearer ${privateStuff.token}`,
    });

    const defaultError = Err("There was an error fetching your posts. Please, try again.");

    try {
      const response = await fetch("/api/posts", { headers });
      const result = await response.json() as Result<Post[], string>;

      if (result._kind === "err") {
        return app.ports.getPosts.send(defaultError);
      }

      const rawPosts = result.data;
      const postsPromises = rawPosts.map(async (post) => {
        const contentResult = await decryptData(post.content, privateStuff.privateKey);
        const content = withDefault(contentResult, "");

        return {
          ...post,
          content: JSON.parse(content),
        }
      });

      Promise.all(postsPromises).then((posts) => app.ports.getPosts.send(Ok(posts)));
    } catch(e) {
      app.ports.getPosts.send(defaultError);
    }
  });
}
