# Repository Atlas: agent-client-tauri

## Project Responsibility
Tauri v2 popup overlay chat client (Hyprland-scratchpad style): a frameless always-on-top window toggled by a global hotkey / `--toggle` second-instance launch. React+Vite frontend talks to the LLM only via Rust `invoke("send_message")` with streaming through `chat_chunk`/`chat_done` events (not yet implemented; `greet` is the sample command). Nix flake provides the reproducible dev shell (Rust toolchain + clippy/rustfmt/rust-analyzer + Tauri Linux system libs).

## System Entry Points
- `src-tauri/src/main.rs`: binary entry, delegates to `agent_client_tauri_lib::run()`.
- `src-tauri/src/lib.rs`: `run()` — Tauri Builder, plugin wiring, IPC handler registration.
- `src/main.tsx`: frontend bootstrap, mounts `<App />` into `#root`.
- `index.html`: WebView host page.
- `flake.nix`: Nix dev environment (`tauri-v2-dev` shell).
- `package.json`: frontend deps + scripts (`dev`, `build` = `tsc && vite build`, `tauri`).
- `src-tauri/Cargo.toml`: backend deps (`tauri v2`, `opener`, desktop-only `single-instance`, `serde/serde_json`).
- `src-tauri/tauri.conf.json`: app identity, window geometry, dev/build hooks, bundle config.

## Directory Map (Aggregated)
| Directory | Responsibility Summary | Detailed Map |
|-----------|------------------------|--------------|
| `src/` | Presentation Layer: React UI rendering, local state, all backend work delegated via Tauri IPC. | [View Map](src/codemap.md) |
| `src-tauri/` | Backend host: overlay window definition, lib+bin crate, Builder/plugin/IPC wiring, event loop. | [View Map](src-tauri/codemap.md) |
| `src-tauri/src/` | Rust sources: `run()` entry, `greet` IPC command, single-instance `--toggle` show/hide helpers. | [View Map](src-tauri/src/codemap.md) |
| `src-tauri/capabilities/` | ACL layer: `default.json` grants `core:default` + `opener:default` to `main`; `desktop.json` grants nothing (deny-by-default). | [View Map](src-tauri/capabilities/codemap.md) |

## Boundary Notes (from AGENTS.md)
- Window/hotkey logic and IPC commands are a learning zone — changes there need explanation + confirmation (Plan mode).
- Frontend never talks to the LLM API directly — only via `invoke("send_message")`.
- Code comments must be in English.
