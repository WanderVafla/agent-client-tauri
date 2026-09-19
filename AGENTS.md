# Popup AI Chat Client

Tauri v2 + React + pnpm. Overlay chat triggered by a global hotkey (similar to a Hyprland scratchpad).

## Architecture
- The frontend never talks to the LLM API directly — only via `invoke("send_message")`
- Streaming happens through Tauri events (`chat_chunk`, `chat_done`), not via the command's return value
- ChatProvider is a trait; implementations are interchangeable (OpenRouter today, agent-notes later)

## Boundaries for the agent
- Do NOT touch without explanation and confirmation: window/hotkey logic (`src-tauri/src/window.rs`),
  IPC commands (`src-tauri/src/commands.rs`) — learning zone, Plan mode only
- Safe to generate autonomously: configs (eslint/prettier/tsconfig), CI, README, scaffolding boilerplate

## Commands
pnpm tauri dev / pnpm build / cargo test

## Rules commenter 
- Comment into code mush be always on english