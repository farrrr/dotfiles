#!/usr/bin/env zx

const neverDelete = "master\\|main\\|develop\\|hotfix\\|temp\\|[0-9]task";

try {
  await $`git branch --merged | grep  -v ${neverDelete} | xargs -n 1 git branch -d`;
} catch (p) {
  console.log(`No merged branches to delete (${p.exitCode})`);
}

let branchLines = "";

try {
  branchLines = await $`git branch --no-merged | grep  -v ${neverDelete}`;
} catch (p) {
  console.log(`No unmerged branches to delete (${p.exitCode})`);
  process.exit(0);
}

const branches = branchLines.stdout
  .split("\n")
  .map((b) => b.trim())
  .filter((b) => b.length > 0);

console.warn("Deleting unmerged branches: ", branches);
for (const branch of branches) {
  const shouldDelete = await question(`delete "${branch}"? [y/N] `);
  if (shouldDelete && shouldDelete[0].toLowerCase() === "y") {
    await $`git branch -D ${branch}`;
  }
}
