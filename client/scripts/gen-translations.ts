import * as CodeGen from "elm-codegen";
import { translations } from "./translations";

CodeGen.run("Translations.elm", {
  debug: true,
  output: "generated",
  flags: translations,
  cwd: "./codegen"
});
