import * as ConcurrentTask from "@andrewmacmurray/elm-concurrent-task";

import { encryptChallenge } from "./tasks/register";
import { buildUser, decryptChallenge } from "./tasks/login";
import { decryptPosts, encryptPost } from "./tasks/posts";

(function() {
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
})();
