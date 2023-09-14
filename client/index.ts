import { handleAccessRequest } from "./handlers/access_request";

(function () {

  const app = window.Elm.App.init({
    node: document.getElementById("app"),
  });

  // let privateKey: CryptoKey | null = null;
  // function setPrivateKey(key: CryptoKey): void {
  //   privateKey = key;
  // }
  // function getPrivateKey(): CryptoKey | null {
  //   return privateKey;
  // }

  handleAccessRequest(app);
})();
