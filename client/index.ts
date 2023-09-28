import * as ConcurrentTask from "@andrewmacmurray/elm-concurrent-task";

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

  app.ports.setTheme.subscribe((data) => {
    // https://css-tricks.com/updating-a-css-variable-with-javascript/
    const root = document.documentElement;

    root.style.setProperty("--background-color", data.backgroundColor);
    root.style.setProperty("--foreground-color", data.foregroundColor);
    root.style.setProperty("--text-color", data.textColor);
    root.style.setProperty("--error-color", data.errorColor);
  });
})();
