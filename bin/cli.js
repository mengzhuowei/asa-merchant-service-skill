#!/usr/bin/env node
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const packageRoot = path.resolve(__dirname, "..");
const skillsSourceRoot = path.join(packageRoot, "asa-merchant-service-skills");

function printUsage() {
  console.log("Usage:");
  console.log("  npx -y <package-name> install [--target <skills_dir>]");
  console.log("");
  console.log("Options:");
  console.log("  --target  Install destination (default: ~/.openclaw/workspace/skills)");
  console.log("");
  console.log("Env:");
  console.log("  OPENCLAW_SKILLS_DIR  Alternate install destination");
}

function parseTarget(argv) {
  const i = argv.indexOf("--target");
  if (i === -1) {
    return null;
  }
  if (i + 1 >= argv.length) {
    throw new Error("Missing value for --target");
  }
  return argv[i + 1];
}

function getSkillDirs(rootDir) {
  if (!fs.existsSync(rootDir)) {
    throw new Error(`Skills source not found: ${rootDir}`);
  }

  const dirs = [];
  const entries = fs.readdirSync(rootDir, { withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isDirectory()) {
      continue;
    }
    const skillDir = path.join(rootDir, entry.name);
    const skillFile = path.join(skillDir, "SKILL.md");
    if (fs.existsSync(skillFile)) {
      dirs.push({ name: entry.name, path: skillDir });
    }
  }
  return dirs;
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function installSkills(skillDirs, targetRoot) {
  ensureDir(targetRoot);
  for (const skill of skillDirs) {
    const targetDir = path.join(targetRoot, skill.name);
    fs.cpSync(skill.path, targetDir, { recursive: true, force: true });
    console.log(`Installed: ${skill.name}`);
  }
}

function main() {
  const argv = process.argv.slice(2);
  const command = argv[0];

  if (!command || command === "-h" || command === "--help") {
    printUsage();
    process.exit(command ? 0 : 1);
  }

  if (command !== "install") {
    console.error(`Unknown command: ${command}`);
    printUsage();
    process.exit(1);
  }

  let cliTarget = null;
  try {
    cliTarget = parseTarget(argv);
  } catch (err) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }

  const defaultTarget = path.join(os.homedir(), ".openclaw", "workspace", "skills");
  const targetRoot = path.resolve(
    cliTarget || process.env.OPENCLAW_SKILLS_DIR || defaultTarget
  );

  try {
    const skills = getSkillDirs(skillsSourceRoot);
    if (skills.length === 0) {
      throw new Error("No skill folders with SKILL.md were found to install.");
    }

    installSkills(skills, targetRoot);
    console.log(`Done. Installed ${skills.length} skills to: ${targetRoot}`);
  } catch (err) {
    console.error(`Install failed: ${err.message}`);
    process.exit(1);
  }
}

main();
