# src-tauri/

## Responsibility
Tauri v2 backend host for the popup overlay chat client: defines app identity/window, builds Rust lib+bin crate, and runs the event loop.

## Design
Tauri Builder pattern in `agent_client_tauri_lib::run()` with plugin wiring for `tauri_plugin_single_instance` (`--toggle` show/hide) and `tauri_plugin_opener`; IPC commands registered via `tauri::generate_handler!`; crate lib+bin layout where `src/main.rs` calls `agent_client_tauri_lib::run()` from `src/lib.rs`; `build.rs` delegates to `tauri_build::build()`; `tauri.conf.json` configures `productName`, `identifier`, dev/build frontend hooks (`pnpm dev`/`pnpm build`, `devUrl http://localhost:1420`, `frontendDist ../dist`), frameless alwaysOnTop skipTaskbar centered `800x600` window, and bundle icons.

## Flow
`cargo/tauri build` -> `build.rs: tauri_build::build()` generates context -> `main(): agent_client_tauri_lib::run()` -> `Builder::default().plugin(single-instance).plugin(opener).invoke_handler[greet].run(generate_context!())`; second instance with `--toggle` triggers show/hide instead of new window.

## Integration
Frontend never calls LLM directly, only via `invoke("send_message")` (future) / `greet` today; `tauri.conf.json` bridges Vite dev server and `../dist`; `capabilities/*.json` ACLs gate frontend API access; `Cargo.toml` pins `tauri v2`, `opener`, `single-instance` (desktop-only), `serde/serde_json`.
