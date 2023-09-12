(() => {
  // handlers/access_request.ts
  function handleAccessRequest(app2) {
    app2.ports.gotAccessRequest.subscribe(console.log);
  }

  // index.ts
  var app = window.Elm.App.init({
    node: document.getElementById("app")
  });
  handleAccessRequest(app);
})();
