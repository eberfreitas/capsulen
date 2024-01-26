import { BuildOptions, build } from "esbuild";
import dotenv from "dotenv";

dotenv.config({ path: "../.env" });

const options: BuildOptions = {
  bundle: true,
  entryPoints: ["./index.ts"],
  outfile: "./../server/public/js/index.js",
  define: {
    "process.env.SENTRY_CLIENT_DSN": JSON.stringify(
      process.env?.SENTRY_CLIENT_DSN || "",
    ),
    "process.env.SENTRY_CLIENT_TARGET": JSON.stringify(
      process.env?.SENTRY_CLIENT_TARGET || "",
    ),
  },
};

(async function() {
  await build(options);
})();
