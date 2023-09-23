import * as ConcurrentTask from "@andrewmacmurray/elm-concurrent-task";

import { handleAccessRequest } from "./handlers/access_request";
import { handleLoginRequest } from "./handlers/login_request";
import { handlePost } from "./handlers/post";
import { handlePosts } from "./handlers/posts";
import { handleToken } from "./handlers/token";
import { encryptChallenge } from "./tasks/register";

(function() {
  const app = window.Elm.App.init();

  ConcurrentTask.register({
    tasks: {
      "register:encryptChallenge": encryptChallenge,
    },
    ports: {
      send: app.ports.taskSend,
      receive: app.ports.taskReceive,
    },
  });

  type PrivateStuff = { token: string; privateKey: CryptoKey };

  let privateStuff: PrivateStuff | null = null;

  function setPrivateStuff(data: {
    token: string;
    privateKey: CryptoKey;
  }): void {
    privateStuff = data;
  }

  function getPrivateStuff(): PrivateStuff {
    if (!privateStuff) {
      throw new Error("Private key and token not defined.");
    }

    return privateStuff;
  }

  handleAccessRequest(app);
  handleLoginRequest(app);
  handleToken(app, setPrivateStuff);
  handlePost(app, getPrivateStuff);
  handlePosts(app, getPrivateStuff);
})();
