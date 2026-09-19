# src-tauri/capabilities/

## Responsibility
Tauri v2 ACL/capability layer declaring which frontend windows on which platforms may use which IPC permissions.

## Design
JSON capabilities: `default.json` (`identifier: default`, `description: Capability for the main window`) scoped to `windows: ["main"]` granting `core:default` and `opener:default`; `desktop.json` (`identifier: desktop-capability`, `platforms: [macOS, windows, linux]`, `windows: ["main"]`) with empty `permissions: []` as deny-by-default placeholder.

## Flow
At `run(generate_context!())`, Tauri loads `capabilities/*.json` -> matches current platform/window (`main`) -> allows only listed permission sets for `invoke`/JS APIs; unlisted APIs are blocked.

## Integration
Enforces frontend-only-via-`invoke` boundary: `core:default` enables base event/window/IPC, `opener:default` enables `opener` plugin used in `lib.rs`; `desktop.json` currently grants nothing, safe extension point for future `send_message`/store/http permissions without touching window/IPC command code.
