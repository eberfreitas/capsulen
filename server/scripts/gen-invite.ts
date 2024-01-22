import { Client } from "pg";
import randomstring from "randomstring";
import { masterInvite } from "../db/queries/invites.queries";

(async function() {
  const db = new Client({
    host: "localhost",
    user: "postgres",
    password: "postgres",
    database: "capsulen",
  });

  await db.connect();

  const code = randomstring.generate({
    length: 8,
    capitalization: "uppercase",
  });

  await masterInvite.run({ code }, db);

  console.log("You can create an user with the following invite code:", code);

  process.exit(0);
})();
