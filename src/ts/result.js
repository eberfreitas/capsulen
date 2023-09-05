"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Err = exports.Ok = void 0;
function Ok(data) {
  return { type: "ok", data };
}
exports.Ok = Ok;
function Err(error) {
  return { type: "err", error };
}
exports.Err = Err;
