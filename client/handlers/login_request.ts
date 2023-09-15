import { Err, Ok, withErr, withOk } from "shared/result";
import { App } from "../@types/global";
import { decryptData, getPasswordKey } from "../crypto";

export function handleLoginRequest(app: App): void {
  app.ports.sendLoginRequest.subscribe(async (data) => {
    const privateKey = await getPasswordKey(data.privateKey);
    const challengeResult = await decryptData(
      data.challengeEncrypted,
      privateKey,
    );

    withOk(challengeResult, (challenge) => {
      app.ports.getLoginChallenge.send(Ok({ username: data.username, challenge }));
    });

    withErr(challengeResult, (e) => {
      // TODO: notify some error handling service here
      app.ports.getLoginChallenge.send(Err(e));
    });
  });
}
