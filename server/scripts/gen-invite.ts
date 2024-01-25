import { Client } from "pg";
import randomstring from "randomstring";
import { masterInvite } from "../db/queries/invites.queries";
import dotenv from "dotenv";
import path from "path";
import parseDatabaseUrl from "ts-parse-database-url";

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

(async function() {
  const dbClientConfig = parseDatabaseUrl(process.env?.DATABASE_URL || "");

  const db = new Client({
    host: dbClientConfig.host || "localhost",
    user: dbClientConfig.user || "postgres",
    password: dbClientConfig.password || "postgres",
    database: dbClientConfig.database || "capsulen",
    port: dbClientConfig.port || 5432,
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
