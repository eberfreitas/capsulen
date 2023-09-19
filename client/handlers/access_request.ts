import { App } from "../@types/global";
import { encryptData, getPasswordKey } from "../crypto";

export function handleAccessRequest(app: App): void {
  app.ports.sendAccessRequest.subscribe(async (data) => {
    try {
      const privateKey = await getPasswordKey(data.privateKey);
      const challengeEncrypted = await encryptData(data.challenge, privateKey);

      app.ports.getChallengeEncrypted.send({
        username: data.username,
        nonce: data.nonce,
        challenge: data.challenge,
        challengeEncrypted,
      });
    } catch (e) {
      app.ports.getError.send(
        e instanceof Error
          ? e.message
          : "Unexpected error while handling your registration request.",
      );
    }
  });
}
