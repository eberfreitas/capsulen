"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.existingUser = void 0;
/** Types generated for queries found in "src/Backend/ts/queries/users.sql" */
const runtime_1 = require("@pgtyped/runtime");
const existingUserIR = { "usedParamSet": { "username": true }, "params": [{ "name": "username", "required": false, "transform": { "type": "scalar" }, "locs": [{ "a": 51, "b": 59 }] }], "statement": "SELECT 1 AS exists FROM users WHERE username ILIKE :username" };
/**
 * Query generated from SQL:
 * ```
 * SELECT 1 AS exists FROM users WHERE username ILIKE :username
 * ```
 */
exports.existingUser = new runtime_1.PreparedQuery(existingUserIR);
