import { withOk } from "shared/result";
import { App } from "../@types/global";
import { encryptData } from "../crypto";

export function handlePost(
  app: App,
  getPrivateStuff: () => { token: string; privateKey: CryptoKey } | null,
): void {
  app.ports.sendPost.subscribe(async (data) => {
    const privateStuff = getPrivateStuff();

    if (!privateStuff) return;

    const contentResult = await encryptData(JSON.stringify(data), privateStuff.privateKey);

    withOk(contentResult, async (content) => {
      const request = await fetch("/api/posts", {
        method: "POST",
        body: content,
        headers: new Headers({
          "content-type": "text/plain",
          "authorization": `Bearer ${privateStuff.token}`,
        }),
      });

      console.log(request);
    });
  });
}
