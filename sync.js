import { spawn } from "child_process";

import { PATHS } from "./paths.js";

const asyncExec = (command) =>
  new Promise((resolve, reject) => {
    const process = spawn("zsh", ["-c", command]);
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

async function syncFile(localSrc, externalSrc) {
  console.log(`Syncing ${localSrc}...`);
  const output = await asyncExec(`curl -o ${localSrc} ${externalSrc}`);
  console.log(output);
}

const externalFiles = PATHS.filter((p) => p.externalSrc);

console.log("Syncing external files...");

let hasError = false;

for (const path of externalFiles) {
  try {
    await syncFile(path.src, path.externalSrc);
  } catch (error) {
    console.error(error);
    hasError = true;
    break;
  }
}

if (!hasError) {
  console.log("Creating diff...");
  for (const { src, dest } of PATHS) {
    try {
      const output = await asyncExec(`diff -Nu ${src} ${dest} | diff-so-fancy`);
      console.log(output);
    } catch (error) {
      console.error(error);
      hasError = true;
    }
  }
}
