import * as ConcurrentTask from "@andrewmacmurray/elm-concurrent-task";
import topbar from "topbar";

import { ColorPalette } from "./@types/global";

import { encryptChallenge } from "./tasks/register";
import { buildUser, decryptChallenge } from "./tasks/login";
import { decryptPosts, encryptPost } from "./tasks/posts";

(function() {
  // const colorScheme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
  // const locale = navigator.language.split("-")[0] ?? "en";

  const app = window.Elm.App.init();

  ConcurrentTask.register({
    tasks: {
      "register:encryptChallenge": encryptChallenge,
      "login:decryptChallenge": decryptChallenge,
      "login:buildUser": buildUser,
      "posts:encryptPost": encryptPost,
      "posts:decryptPosts": decryptPosts,
    },
    ports: {
      send: app.ports.taskSend,
      receive: app.ports.taskReceive,
    },
  });

  let colorPalette: ColorPalette | null = null;

  app.ports.setTheme.subscribe((data) => {
    // https://css-tricks.com/updating-a-css-variable-with-javascript/
    const root = document.documentElement;

    root.style.setProperty("--background-color", data.backgroundColor);
    root.style.setProperty("--foreground-color", data.foregroundColor);
    root.style.setProperty("--text-color", data.textColor);
    root.style.setProperty("--error-color", data.errorColor);

    colorPalette = data;
  });

  let loading = false;

  app.ports.toggleLoader.subscribe(() => {
    topbar.config({
      barColors: {
        "0": colorPalette?.foregroundColor ?? "rgb(0, 0, 0 / 1.0)",
        "1": colorPalette?.textColor ?? "rgb(0, 0, 0 / 1.0)",
      }
    });

    if (loading) {
      topbar.hide();
      loading = false;
    } else {
      topbar.show(250);
      loading = true;
    }
  });
})();
