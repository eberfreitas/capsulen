import { handleAccessRequest } from "./handlers/access_request";
import { handleLoginRequest } from "./handlers/login_request";
import { handleToken } from "./handlers/token";

(function () {

  const app = window.Elm.App.init();

  let privateStuff: { token: string; privateKey: CryptoKey } | null = null;

  function setPrivateStuff(data: { token: string; privateKey: CryptoKey }): void {
    privateStuff = data;

    console.log(privateStuff);
  }

  handleAccessRequest(app);
  handleLoginRequest(app);
  handleToken(app, setPrivateStuff);
})();
