import { App } from "../@types/global";
import { encryptData, getPasswordKey } from "../crypto";
import { Ok, Err } from "shared/result";

export function handleAccessRequest(
  app: App,
  setPrivateKey: (key: CryptoKey) => void,
): void {
  app.ports.sendAccessRequest.subscribe(async (data) => {
    try {
      const privateKey = await getPasswordKey(data.privateKey);
      const challengeEncrypted = await encryptData(data.challenge, privateKey);

      setPrivateKey(privateKey);

      const result = Ok({
        username: data.username,
        nonce: data.nonce,
        challenge: data.challenge,
        challengeEncrypted,
      });

      app.ports.getChallengeEncrypted.send(result);
    } catch (e: unknown) {
      // TODO: notify some error handling service here
      const result = Err(
        e instanceof Error
          ? e.message
          : "Unknown error when generating encrypted challenge",
      );

      app.ports.getChallengeEncrypted.send(result);
    }
  });
}
