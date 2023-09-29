import {
  TaskDefinition,
  TaskResult,
} from "@andrewmacmurray/elm-concurrent-task";

interface ColorPalette {
  backgroundColor: string;
  foregroundColor: string;
  textColor: string;
  errorColor: string;
}

export interface App {
  ports: {
    taskSend: {
      subscribe: (callback: (defs: TaskDefinition[]) => Promise<void>) => void;
    };

    taskReceive: {
      send: (result: TaskResult[]) => void;
    };

    setTheme: {
      subscribe: (callback: (palette: ColorPalette) => void) => void;
    };

    toggleLoader: {
      subscribe: (callback: () => void) => void;
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
