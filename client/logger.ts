import {
  captureException as captureExceptionSentry,
  captureMessage as captureMessageSentry,
} from "@sentry/browser";

let captureExceptionFn: ((param: unknown) => void) | null = null;
let captureMessageFn: ((param: string) => void) | null = null;

export function captureException(exception: unknown): void {
  if (captureExceptionFn) return captureExceptionFn(exception);

  if (process.env.SENTRY_CLIENT_DSN) {
    captureExceptionFn = captureExceptionSentry;
  } else {
    captureExceptionFn = console.error;
  }

  return captureExceptionFn(exception);
}

export function captureMessage(message: string): void {
  if (captureMessageFn) return captureMessageFn(message);

  if (process.env.SENTRY_CLIENT_DSN) {
    captureMessageFn = captureMessageSentry;
  } else {
    captureMessageFn = console.log;
  }

  return captureMessageFn(message);
}
