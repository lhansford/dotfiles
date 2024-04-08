import { spawn } from "child_process";
import { createInterface } from "readline";

import { PATHS } from "./paths.js";
import { mkdirSync } from "fs";
import { dirname } from "path";

function asyncExec(command, shellCommand = "zsh") {
  return new Promise((resolve, reject) => {
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

async function prompt(message) {
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

async function syncExternalFile(localSrc, externalSrc) {
  console.log(`Syncing ${localSrc}...`);
  const output = await asyncExec(`curl -o ${localSrc} ${externalSrc}`);
  console.log(output);
}

async function symlinkFile(target, linkName) {
  console.log(`Symlinking ${target} to ${linkName}...`);
  console.log(`ln -sf ${target} ${linkName}`);
  const output = await asyncExec(`ln -sf ${target} ${linkName}`);
  console.log(output);
}

let hasError = false;

const externalFiles = PATHS.filter((p) => p.externalSrc);
console.log("Syncing external files...");
for (const path of externalFiles) {
  try {
    await syncExternalFile(path.src, path.externalSrc);
  } catch (error) {
    console.error(error);
    hasError = true;
    break;
  }
}

let diffLength = 0;
if (!hasError) {
  console.log("Creating diff...");
  for (const { src, dest } of PATHS) {
    try {
      const output = await asyncExec(`diff -Nu ${src} ${dest} | diff-so-fancy`);
      console.log(output);
      diffLength += output.length;
    } catch (error) {
      console.error(error);
      hasError = true;
    }
  }
}

if (diffLength === 0) {
  console.log("No changes found. You're up to date!");
} else if (!hasError) {
  const promptResponse = await prompt("Do you want to apply the diff? (y/n)");
  if (promptResponse === "y") {
    console.log("Symlinking files...");
    for (const { src, dest } of PATHS) {
      try {
        const createdDir = mkdirSync(dirname(dest), { recursive: true });
        if (createdDir) {
          console.log(`Created directory: ${createdDir}`);
        }
        await symlinkFile(src, dest);
      } catch (error) {
        console.error(error);
        hasError = true;
      }
    }
  }
}
