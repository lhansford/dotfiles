#!/usr/bin/env node
import { argv, exit } from "process";

// TODO: Would be nice to run this in the background
function createTask(text) {
  fetch("https://api.todoist.com/rest/v2/tasks", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${process.env.TODOIST_API_TOKEN}`,
    },
    body: JSON.stringify({
      content: text,
    }),
  }).then(() => {
    exit(0);
  })
    .catch((e) => console.error(e));
}

if (argv.length > 2) {
  const text = argv[2];
  createTask(text);
}
