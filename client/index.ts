import * as ConcurrentTask from "@andrewmacmurray/elm-concurrent-task";
import topbar from "topbar";
import * as Sentry from "@sentry/browser";

import { ColorPalette } from "./@types/global";

import { encryptChallenge } from "./tasks/register";
import { buildUser, decryptChallenge } from "./tasks/login";
import { decryptPosts, deleteConfirm, encryptPost } from "./tasks/posts";
import { get, set } from "./local-storage";
import { captureMessage } from "./logger";

if (process.env.SENTRY_CLIENT_DSN) {
  const targets: (string | RegExp)[] = ["localhost"];

  if (process.env.SENTRY_CLIENT_TARGET) {
    targets.push(new RegExp(process.env.SENTRY_CLIENT_TARGET));
  }

  Sentry.init({
    dsn: process.env.SENTRY_CLIENT_DSN,
    integrations: [
      new Sentry.BrowserTracing({
        tracePropagationTargets: targets,
      }),
    ],
    tracesSampleRate: 1.0,
    replaysSessionSampleRate: 0.1,
  });
}

(function() {
  const username = get("username");
  const colorScheme = window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
  const language = navigator.language.split("-")[0] ?? "en";

  const app = window.Elm.App.init({
    flags: { colorScheme, language, username },
  });

  ConcurrentTask.register({
    tasks: {
      "register:encryptChallenge": encryptChallenge,
      "login:decryptChallenge": decryptChallenge,
      "login:buildUser": buildUser,
      "posts:encryptPost": encryptPost,
      "posts:decryptPosts": decryptPosts,
      "posts:deleteConfirm": deleteConfirm,
    },
    ports: {
      send: app.ports.taskSend,
      receive: app.ports.taskReceive,
    },
  });

  let theme: ColorPalette | null = null;

  app.ports.setTheme.subscribe((data) => {
    theme = data;
  });

  let loading = false;

  app.ports.toggleLoader.subscribe(() => {
    topbar.config({
      barColors: {
        "0": theme?.foreground ?? "rgb(0, 0, 0 / 1.0)",
        "1": theme?.text ?? "rgb(0, 0, 0 / 1.0)",
      },
    });

    if (loading) {
      topbar.hide();
      loading = false;
    } else {
      topbar.show(250);
      loading = true;
    }
  });

  app.ports.localStorageSet.subscribe((data) => {
    set(data.key, data.value);
  });

  app.ports.logMessage.subscribe(captureMessage);
})();
