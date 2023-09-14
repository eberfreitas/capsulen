import { App } from "../@types/global";
import { encryptData, getPasswordKey } from "../crypto";
import { Ok, Err, withOk, withErr } from "shared/result";

export function handleAccessRequest(app: App): void {
  app.ports.sendAccessRequest.subscribe(async (data) => {
    const privateKey = await getPasswordKey(data.privateKey);
    const challengeEncryptedResult = await encryptData(
      data.challenge,
      privateKey,
    );

    withOk(challengeEncryptedResult, (challengeEncrypted) => {
      const result = Ok({
        username: data.username,
        nonce: data.nonce,
        challenge: data.challenge,
        challengeEncrypted,
      });

      app.ports.getChallengeEncrypted.send(result);
    });

    withErr(challengeEncryptedResult, (e) => {
      // TODO: notify some error handling service here
      app.ports.getChallengeEncrypted.send(Err(e));
    });
  });
}
