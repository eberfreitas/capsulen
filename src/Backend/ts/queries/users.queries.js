"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createUserRequest = exports.existingUser = void 0;
/** Types generated for queries found in "src/Backend/ts/queries/users.sql" */
const runtime_1 = require("@pgtyped/runtime");
const existingUserIR = {
  usedParamSet: { username: true },
  params: [
    {
      name: "username",
      required: false,
      transform: { type: "scalar" },
      locs: [{ a: 51, b: 59 }],
    },
  ],
  statement:
    "SELECT 1 AS exists FROM users WHERE username ILIKE :username LIMIT 1",
};
/**
 * Query generated from SQL:
 * ```
 * SELECT 1 AS exists FROM users WHERE username ILIKE :username LIMIT 1
 * ```
 */
exports.existingUser = new runtime_1.PreparedQuery(existingUserIR);
const createUserRequestIR = {
  usedParamSet: { user: true },
  params: [
    {
      name: "user",
      required: false,
      transform: {
        type: "pick_tuple",
        keys: [
          { name: "username", required: false },
          { name: "nonce", required: false },
          { name: "challenge", required: false },
        ],
      },
      locs: [{ a: 54, b: 58 }],
    },
  ],
  statement: "INSERT INTO users (username, nonce, challenge) VALUES :user",
};
/**
 * Query generated from SQL:
 * ```
 * INSERT INTO users (username, nonce, challenge) VALUES :user
 * ```
 */
exports.createUserRequest = new runtime_1.PreparedQuery(createUserRequestIR);
