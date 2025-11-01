import { mkdirSync } from "fs";
import { dirname } from "path";

import terminalKit from "terminal-kit";

import { PATHS, SYSTEMS } from "./paths.js";
import { asyncExec, getSelection, prompt } from "./src/terminal.js";

const { terminal } = terminalKit;

async function syncExternalFile(localSrc, externalSrc) {
  terminal(`Syncing ${localSrc}...\n`);
  const output = await asyncExec(`curl -o ${localSrc} ${externalSrc}`);
  console.log(output);
}

async function symlinkFile(target, linkName) {
  terminal(`Symlinking ${target} to ${linkName}...\n`);
  const output = await asyncExec(`ln -sf ${target} ${linkName}`);
  console.log(output);
}

let hasError = false;

const os = await getSelection(Object.values(SYSTEMS), "Select your OS:");
const osPaths = PATHS.filter((p) => p.systems?.includes(os));
const externalFiles = osPaths.filter((p) => p.externalSrc);

terminal.bold("Syncing external files...\n\n");

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
  terminal.bold("Creating diff...\n\n");
  for (const { src, dest } of osPaths) {
    try {
      const output = await asyncExec(`diff -Nu ${dest} ${src} | diff-so-fancy`);
      console.log(output);
      diffLength += output.length;
    } catch (error) {
      console.error(error);
      hasError = true;
    }
  }
}

if (diffLength === 0) {
  terminal.green.bold("No changes found. You're up to date!\n");
} else if (!hasError) {
  const promptResponse = await prompt("Do you want to apply the diff? (y/n)");
  if (promptResponse === "y") {
    terminal.bold("Symlinking files...\n\n");
    for (const { src, dest } of osPaths) {
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

if (os === SYSTEMS.linux) {
  const promptResponse = await prompt("Sync PaperWM config? (y/n)");
  if (promptResponse === "y") {
    try {
      await asyncExec(
        "dconf load /org/gnome/shell/extensions/paperwm/ < ./paperwm/paperwm.dconf"
      );
      terminal.green.bold("PaperWM config synced successfully.\n");
    } catch (error) {
      console.error(error);
      hasError = true;
    }
  }
}

process.exit(hasError ? 1 : 0);
