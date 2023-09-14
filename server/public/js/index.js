(() => {
  // crypto.ts
  var enc = new TextEncoder();
  var dec = new TextDecoder();
  function buffToBase64(buff) {
    return btoa(
      new Uint8Array(buff).reduce(
        (data, byte) => data + String.fromCharCode(byte),
        ""
      )
    );
  }
  async function deriveKey(passwordKey, salt, keyUsage) {
    return window.crypto.subtle.deriveKey(
      {
        name: "PBKDF2",
        salt,
        iterations: 25e4,
        hash: "SHA-256"
      },
      passwordKey,
      { name: "AES-GCM", length: 256 },
      false,
      keyUsage
    );
  }
  async function getPasswordKey(password) {
    return window.crypto.subtle.importKey(
      "raw",
      enc.encode(password),
      "PBKDF2",
      false,
      ["deriveKey"]
    );
  }
  async function encryptData(secretData, passwordKey) {
    try {
      const salt = window.crypto.getRandomValues(new Uint8Array(16));
      const iv = window.crypto.getRandomValues(new Uint8Array(12));
      const aesKey = await deriveKey(passwordKey, salt, ["encrypt"]);
      const encryptedContent = await window.crypto.subtle.encrypt(
        {
          name: "AES-GCM",
          iv
        },
        aesKey,
        enc.encode(secretData)
      );
      const encryptedContentArr = new Uint8Array(encryptedContent);
      const buff = new Uint8Array(
        salt.byteLength + iv.byteLength + encryptedContentArr.byteLength
      );
      buff.set(salt, 0);
      buff.set(iv, salt.byteLength);
      buff.set(encryptedContentArr, salt.byteLength + iv.byteLength);
      const base64Buff = buffToBase64(buff);
      return base64Buff;
    } catch (e) {
      console.log(`Error - ${e}`);
      return "";
    }
  }

  // ../shared/result.ts
  function Ok(data) {
    return { _kind: "ok", data };
  }
  function Err(error) {
    return { _kind: "err", error };
  }

  // handlers/access_request.ts
  function handleAccessRequest(app, setPrivateKey) {
    app.ports.sendAccessRequest.subscribe(async (data) => {
      try {
        const privateKey = await getPasswordKey(data.privateKey);
        const challengeEncrypted = await encryptData(data.challenge, privateKey);
        setPrivateKey(privateKey);
        const result = Ok({
          username: data.username,
          nonce: data.nonce,
          challenge: data.challenge,
          challengeEncrypted
        });
        app.ports.getChallengeEncrypted.send(result);
      } catch (e) {
        const result = Err(
          e instanceof Error ? e.message : "Unknown error when generating encrypted challenge"
        );
        app.ports.getChallengeEncrypted.send(result);
      }
    });
  }

  // index.ts
  (function() {
    let privateKey = null;
    const app = window.Elm.App.init({
      node: document.getElementById("app")
    });
    function setPrivateKey(key) {
      privateKey = key;
    }
    handleAccessRequest(app, setPrivateKey);
  })();
})();
