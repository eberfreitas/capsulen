import { App } from "../@types/global";
import { decryptData, getPasswordKey } from "../crypto";

export function handleLoginRequest(app: App): void {
  app.ports.sendLoginRequest.subscribe(async (data) => {
    try {
      const privateKey = await getPasswordKey(data.privateKey);
      const challenge = await decryptData(data.challengeEncrypted, privateKey);

      app.ports.getLoginChallenge.send({ username: data.username, challenge });
    } catch (e) {
      app.ports.getError.send(
        e instanceof Error
          ? e.message
          : "Unexpected error while handling your login request.",
      );
    }
  });
}
