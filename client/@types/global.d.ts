export interface App {
  ports: {
    sendAccessRequest: {
      subscribe: (
        callback: (data: {
          username: string;
          privateKey: string;
          nonce: string;
          challenge: string;
        }) => void,
      ) => void;
    };

    sendLoginRequest: {
      subscribe: (
        callback: (data: {
          username: string;
          privateKey: string;
          challengeEncrypted: string;
        }) => void,
      ) => void;
    };

    sendToken: {
      subscribe: (
        callback: (data: { privateKey: string; token: string }) => void,
      ) => void;
    };

    getChallengeEncrypted: {
      send: (data: unknown) => void;
    };

    getLoginChallenge: {
      send: (data: unknown) => void;
    };
  };
}

interface Elm {
  App: {
    init: () => App;
  };
}

declare global {
  interface Window {
    Elm: Elm;
  }
}
