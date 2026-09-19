# src/

## Responsibility
Presentation Layer of the Tauri v2 application: owns React UI rendering, local UI state, and user input capture. It performs no business logic or LLM access directly; all backend work is delegated via Tauri IPC.

## Design
Component composition with a single functional root component (`App` in `App.tsx`) using React `useState` hooks for `name` and `greetMsg` local state. Flat module structure: `main.tsx` (bootstrap / mount), `App.tsx` (view + controller), `App.css` (view styling with flex layout, light/dark `prefers-color-scheme` theming), `vite-env.d.ts` (Vite client type shim for static assets and env). Unidirectional data flow: input `onChange` -> state -> async `invoke` -> state update -> re-render.

## Flow
1. `main.tsx` -> `App`: `ReactDOM.createRoot(#root)` renders `<React.StrictMode><App /></React.StrictMode>`.
2. `App.tsx` renders static logos/links plus controlled form (`#greet-input` + submit button).
3. User types -> `onChange` updates `name` state; submit `preventDefault()` calls `greet()`.
4. `greet()` performs IPC via `invoke("greet", { name })` from `@tauri-apps/api/core`, awaits `string` result.
5. `setGreetMsg(result)` triggers re-render to display `<p>{greetMsg}</p>`.

## Integration
Consumed by: Vite build (bundles `main.tsx`/`App.tsx`/`App.css` into WebView `dist`, mounted via `index.html` `#root`). Depends on: Tauri JS API (`@tauri-apps/api/core` `invoke`), backend commands registered in `src-tauri/src/lib.rs` (currently `greet`; future `send_message` with `chat_chunk`/`chat_done` streaming events), static assets (`assets/react.svg`, `public/vite.svg`, `public/tauri.svg`).
