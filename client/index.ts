import { handleAccessRequest } from "./handlers/access_request";
import { handleLoginRequest } from "./handlers/login_request";
import { handlePost } from "./handlers/post";
import { handlePosts } from "./handlers/posts";
import { handleToken } from "./handlers/token";

(function() {
  const app = window.Elm.App.init();

  type PrivateStuff = { token: string; privateKey: CryptoKey };

  let privateStuff: PrivateStuff | null = null;

  function setPrivateStuff(data: {
    token: string;
    privateKey: CryptoKey;
  }): void {
    privateStuff = data;
  }

  function getPrivateStuff(): PrivateStuff | null {
    return privateStuff;
  }

  handleAccessRequest(app);
  handleLoginRequest(app);
  handleToken(app, setPrivateStuff);
  handlePost(app, getPrivateStuff);
  handlePosts(app, getPrivateStuff);
})();
