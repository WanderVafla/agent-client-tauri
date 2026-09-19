# src-tauri/src/

## Responsibility
Rust sources for app entrypoint, demo IPC command, and single-instance window toggle logic.

## Design
`run()` as `#[cfg_attr(mobile, tauri::mobile_entry_point)]` public entry using `tauri::Builder`; `#[tauri::command] fn greet(name: &str) -> String` sample IPC; `toggle_main_window(app: &AppHandle, args: &[String])` guard filtering for `--toggle` with `eprintln!` error log; `toggle_main_window_inner(app: &AppHandle) -> tauri::Result<()>` helper using `Manager::get_webview_window("main").ok_or(Error::WebviewNotFound)` then `is_visible/hide/show`; `main.rs` minimal bin with `windows_subsystem` attr delegating to lib.

## Flow
Process start -> `main.rs:main()` -> `lib.rs:run()` -> Builder plugins init -> `generate_handler![greet]` + `generate_context!().run()`; second-process args -> `single_instance::init` callback -> `toggle_main_window` -> `toggle_main_window_inner` -> get `main` window -> hide if visible else show.

## Integration
Exposes `greet` to frontend via `generate_handler!` (pattern for future `send_message` streaming via `chat_chunk`/`chat_done` events); depends on `Manager` trait for window lookup; `single-instance` plugin (see `Cargo.toml` desktop-only dep) enforces one overlay instance for hotkey/scratchpad behavior; `opener` plugin enables external URLs.
