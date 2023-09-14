import { handleAccessRequest } from "./handlers/access_request";

(function () {
  let privateKey: CryptoKey | null = null;

  const app = window.Elm.App.init({
    node: document.getElementById("app"),
  });

  function setPrivateKey(key: CryptoKey): void {
    privateKey = key;
  }

  // function getPrivateKey(): CryptoKey | null {
  //   return privateKey;
  // }

  handleAccessRequest(app, setPrivateKey);
})();
