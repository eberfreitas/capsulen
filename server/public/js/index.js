(() => {
  // ../shared/result.ts
  function Ok(data) {
    return { _kind: "ok", data };
  }
  function Err(error) {
    return { _kind: "err", error };
  }
  function withOk(result, callback) {
    if (result._kind === "ok") {
      return callback(result.data);
    }
    return null;
  }
  function withErr(result, callback) {
    if (result._kind === "err") {
      return callback(result.error);
    }
    return null;
  }

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
  function base64ToBuf(b64) {
    return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
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
      return Ok(base64Buff);
    } catch (e) {
      return Err(e instanceof Error ? e.message : "Unknown encrypting error.");
    }
  }
  async function decryptData(encryptedData, passwordKey) {
    try {
      const encryptedDataBuff = base64ToBuf(encryptedData);
      const salt = encryptedDataBuff.slice(0, 16);
      const iv = encryptedDataBuff.slice(16, 16 + 12);
      const data = encryptedDataBuff.slice(16 + 12);
      const aesKey = await deriveKey(passwordKey, salt, ["decrypt"]);
      const decryptedContent = await window.crypto.subtle.decrypt(
        {
          name: "AES-GCM",
          iv
        },
        aesKey,
        data
      );
      return Ok(dec.decode(decryptedContent));
    } catch (e) {
      return Err(e instanceof Error ? e.message : "Unknown decrypting error.");
    }
  }

  // handlers/access_request.ts
  function handleAccessRequest(app) {
    app.ports.sendAccessRequest.subscribe(async (data) => {
      const privateKey = await getPasswordKey(data.privateKey);
      const challengeEncryptedResult = await encryptData(
        data.challenge,
        privateKey
      );
      withOk(challengeEncryptedResult, (challengeEncrypted) => {
        const result = Ok({
          username: data.username,
          nonce: data.nonce,
          challenge: data.challenge,
          challengeEncrypted
        });
        app.ports.getChallengeEncrypted.send(result);
      });
      withErr(challengeEncryptedResult, (e) => {
        app.ports.getChallengeEncrypted.send(Err(e));
      });
    });
  }

  // handlers/login_request.ts
  function handleLoginRequest(app) {
    app.ports.sendLoginRequest.subscribe(async (data) => {
      const privateKey = await getPasswordKey(data.privateKey);
      const challengeResult = await decryptData(
        data.challengeEncrypted,
        privateKey
      );
      withOk(challengeResult, (challenge) => {
        app.ports.getLoginChallenge.send(Ok({ username: data.username, challenge }));
      });
      withErr(challengeResult, (e) => {
        app.ports.getLoginChallenge.send(Err(e));
      });
    });
  }

  // index.ts
  (function() {
    const app = window.Elm.App.init({
      node: document.getElementById("app")
    });
    handleAccessRequest(app);
    handleLoginRequest(app);
  })();
})();
