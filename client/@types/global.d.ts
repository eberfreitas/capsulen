import {
  TaskDefinition,
  TaskResult,
} from "@andrewmacmurray/elm-concurrent-task";

interface ColorPalette {
  background: string;
  foreground: string;
  text: string;
  error: string;
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
    init: (args: { flags: { colorScheme: string; language: string } }) => App;
  };
}

declare global {
  interface Window {
    Elm: Elm;
  }
}
