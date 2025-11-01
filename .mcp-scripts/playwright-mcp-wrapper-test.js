#!/usr/bin/env node

/**
 * Playwright MCP Wrapper - TEST VERSION
 *
 * Uses -WRAPPERTEST suffix to verify wrapper is working
 */

const os = require('os');
const path = require('path');
const { spawn } = require('child_process');

// Get user home directory (cross-platform)
const homeDir = os.homedir();

// TEST: Use different folder name to verify wrapper works
const profileDir = path.join(homeDir, '.playwright-persistent-WRAPPERTEST');

// Parse command line arguments
const additionalArgs = process.argv.slice(2);

// Build args for @playwright/mcp
const args = [
  '-y',
  '@playwright/mcp',
  '--user-data-dir',
  profileDir,
  ...additionalArgs
];

// Debug logging
console.error(`[playwright-mcp-wrapper-test] Home directory: ${homeDir}`);
console.error(`[playwright-mcp-wrapper-test] Profile directory: ${profileDir}`);
console.error(`[playwright-mcp-wrapper-test] Spawning: npx ${args.join(' ')}`);

// Spawn npx with @playwright/mcp
// Use shell: true to find npx in PATH
const child = spawn('npx', args, {
  stdio: 'inherit',
  shell: true
});

// Forward exit code
child.on('exit', (code, signal) => {
  if (signal) {
    console.error(`[playwright-mcp-wrapper-test] Process killed by signal: ${signal}`);
    process.exit(1);
  }
  process.exit(code || 0);
});

// Handle errors
child.on('error', (err) => {
  console.error(`[playwright-mcp-wrapper-test] Failed to start process: ${err.message}`);
  process.exit(1);
});
