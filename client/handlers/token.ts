import { App } from "../@types/global";
import { getPasswordKey } from "../crypto";

export function handleToken(
  app: App,
  setPrivateStuff: (data: { token: string; privateKey: CryptoKey }) => void,
): void {
  app.ports.sendToken.subscribe(async (data) => {
    const privateKey = await getPasswordKey(data.privateKey);

    setPrivateStuff({ ...data, privateKey });
  });
}
