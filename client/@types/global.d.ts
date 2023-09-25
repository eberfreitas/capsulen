import {
  TaskDefinition,
  TaskResult,
} from "@andrewmacmurray/elm-concurrent-task";

export interface App {
  ports: {
    taskSend: {
      subscribe: (callback: (defs: TaskDefinition[]) => Promise<void>) => void;
    };
    taskReceive: {
      send: (result: TaskResult[]) => void;
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
