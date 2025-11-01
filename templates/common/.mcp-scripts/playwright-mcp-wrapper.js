#!/usr/bin/env node

/**
 * Playwright MCP Wrapper
 *
 * Purpose: Resolve user home directory dynamically for cross-platform compatibility
 *
 * Problem: MCP .mcp.json doesn't expand environment variables in args
 * Solution: Use Node.js to resolve home directory and spawn @playwright/mcp
 *
 * Usage: Called from .mcp.json instead of direct npx invocation
 */

const os = require('os');
const path = require('path');
const { spawn } = require('child_process');

// Get user home directory (cross-platform)
const homeDir = os.homedir();

// Construct persistent profile path
// Windows: C:\Users\Username\.playwright-persistent
// macOS: /Users/username/.playwright-persistent
// Linux: /home/username/.playwright-persistent
const profileDir = path.join(homeDir, '.playwright-persistent');

// Parse command line arguments (everything after this script)
const additionalArgs = process.argv.slice(2);

// Build args for @playwright/mcp
const args = [
  '-y',
  '@playwright/mcp',
  '--user-data-dir',
  profileDir,
  ...additionalArgs  // Pass through any additional arguments
];

// Debug logging (optional, comment out in production)
console.error(`[playwright-mcp-wrapper] Home directory: ${homeDir}`);
console.error(`[playwright-mcp-wrapper] Profile directory: ${profileDir}`);
console.error(`[playwright-mcp-wrapper] Spawning: npx ${args.join(' ')}`);

// Spawn npx with @playwright/mcp
// Use shell: true to find npx in PATH (Windows/Unix compatible)
const child = spawn('npx', args, {
  stdio: 'inherit',  // Inherit stdin, stdout, stderr from parent
  shell: true        // Use shell to resolve npx in PATH
});

// Forward exit code
child.on('exit', (code, signal) => {
  if (signal) {
    console.error(`[playwright-mcp-wrapper] Process killed by signal: ${signal}`);
    process.exit(1);
  }
  process.exit(code || 0);
});

// Handle errors
child.on('error', (err) => {
  console.error(`[playwright-mcp-wrapper] Failed to start process: ${err.message}`);
  process.exit(1);
});
