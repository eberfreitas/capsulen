import { handleAccessRequest } from "./handlers/access_request";

const app = window.Elm.App.init({
  node: document.getElementById("app"),
});

handleAccessRequest(app);
