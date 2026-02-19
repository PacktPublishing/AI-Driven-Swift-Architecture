#!/usr/bin/env node

import { spawn } from "child_process";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const binaryPath = join(__dirname, "../dist/weather-mcp-server");

const child = spawn(binaryPath, {
  stdio: ["pipe", "pipe", "inherit"],
  env: process.env
});

// Forward stdin from Node → Swift
process.stdin.pipe(child.stdin);

// Forward stdout from Swift → Node → Claude
child.stdout.pipe(process.stdout);

// Handle exit
child.on("exit", (code) => {
  process.exit(code ?? 0);
});