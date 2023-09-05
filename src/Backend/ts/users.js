"use strict";
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value);
          });
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value));
        } catch (e) {
          reject(e);
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value));
        } catch (e) {
          reject(e);
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected);
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
  };
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod };
  };
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleUserAccessRequest = void 0;
const randomstring_1 = __importDefault(require("randomstring"));
const users_queries_1 = require("./queries/users.queries");
const result_1 = require("../../ts/result");
function handleUserAccessRequest(app, db, data) {
  return __awaiter(this, void 0, void 0, function* () {
    const requestId = data.requestId;
    const user = {
      username: data.username,
      nonce: `${Math.floor(Math.random() * 999999999)}`,
      challenge: randomstring_1.default.generate(),
    };
    // const exists = await existingUser.run({ username: data.username }, db);
    // if (exists.length > 0) {
    //   const data = Err<string, typeof user>("Username is already used. Please, pick a different username.");
    //   app.ports.gotAccessRequest.send({ requestId, data });
    //   return;
    // }
    try {
      yield users_queries_1.createUserRequest.run({ user }, db);
      app.ports.gotAccessRequest.send({
        requestId,
        data: (0, result_1.Ok)(user),
      });
    } catch (e) {
      const data = (0, result_1.Err)(
        "There was an error creating your user request. Plase, try again.",
      );
      app.ports.gotAccessRequest.send({ requestId, data });
    }
  });
}
exports.handleUserAccessRequest = handleUserAccessRequest;
