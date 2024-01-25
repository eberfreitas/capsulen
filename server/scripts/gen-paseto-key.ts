import { V4 as paseto } from "paseto";

(async function() {
  const key = await paseto.generateKey("public");
  const base64key = paseto.keyObjectToBytes(key).toString("base64");

  console.log(`Use this value as your PASETO_KEY env var:\n${base64key}`);
})();
