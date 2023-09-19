// Based on https://github.com/bradyjoslin/webcrypto-example

const enc = new TextEncoder();

const dec = new TextDecoder();

function buffToBase64(buff: Iterable<number>): string {
  return btoa(
    new Uint8Array(buff).reduce(
      (data, byte) => data + String.fromCharCode(byte),
      "",
    ),
  );
}

function base64ToBuf(b64: string): Uint8Array {
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
}

async function deriveKey(
  passwordKey: CryptoKey,
  salt: BufferSource,
  keyUsage: KeyUsage[],
): Promise<CryptoKey> {
  return window.crypto.subtle.deriveKey(
    {
      name: "PBKDF2",
      salt: salt,
      iterations: 250000,
      hash: "SHA-256",
    },
    passwordKey,
    { name: "AES-GCM", length: 256 },
    false,
    keyUsage,
  );
}

export async function getPasswordKey(password: string): Promise<CryptoKey> {
  return window.crypto.subtle.importKey(
    "raw",
    enc.encode(password),
    "PBKDF2",
    false,
    ["deriveKey"],
  );
}

export async function encryptData(
  secretData: string,
  passwordKey: CryptoKey,
): Promise<string> {
  const salt = window.crypto.getRandomValues(new Uint8Array(16));
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const aesKey = await deriveKey(passwordKey, salt, ["encrypt"]);

  const encryptedContent = await window.crypto.subtle.encrypt(
    {
      name: "AES-GCM",
      iv: iv,
    },
    aesKey,
    enc.encode(secretData),
  );

  const encryptedContentArr = new Uint8Array(encryptedContent);
  const buff = new Uint8Array(
    salt.byteLength + iv.byteLength + encryptedContentArr.byteLength,
  );

  buff.set(salt, 0);
  buff.set(iv, salt.byteLength);
  buff.set(encryptedContentArr, salt.byteLength + iv.byteLength);

  const base64Buff = buffToBase64(buff);

  return base64Buff;
}

export async function decryptData(
  encryptedData: string,
  passwordKey: CryptoKey,
): Promise<string> {
  const encryptedDataBuff = base64ToBuf(encryptedData);
  const salt = encryptedDataBuff.slice(0, 16);
  const iv = encryptedDataBuff.slice(16, 16 + 12);
  const data = encryptedDataBuff.slice(16 + 12);
  const aesKey = await deriveKey(passwordKey, salt, ["decrypt"]);

  const decryptedContent = await window.crypto.subtle.decrypt(
    {
      name: "AES-GCM",
      iv: iv,
    },
    aesKey,
    data,
  );

  return dec.decode(decryptedContent);
}
