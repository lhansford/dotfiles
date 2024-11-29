import { spawn } from "child_process";
import { createInterface } from "readline";

import terminalKit from "terminal-kit";

const terminal = terminalKit.terminal;

export function getSelection(options) {
  return new Promise((resolve, reject) => {
    terminal.singleColumnMenu(options, (error, response) => {
      if (error) {
        reject(error);
      } else {
        resolve(response.selectedText);
      }
    });
  });
}

export async function asyncExec(command, shellCommand = "zsh") {
  return new Promise((resolve, reject) => {
    console.log(command);
    const process = spawn(shellCommand, ["-c", command]);
    let data = "";
    let error = "";
    process.stdout.on("data", (stdout) => {
      data += stdout.toString();
    });
    process.stderr.on("data", (stderr) => {
      error += stderr.toString();
    });
    process.on("error", (err) => {
      reject(err);
    });
    process.on("close", (code) => {
      if (code !== 0) {
        reject(error);
      } else {
        resolve(data);
      }
      process.stdin.end();
    });
  });
}

export async function prompt(message) {
  const _interface = createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  return new Promise((resolve) => {
    _interface.question(message, (response) => {
      _interface.pause();
      resolve(response);
    });
  });
}
