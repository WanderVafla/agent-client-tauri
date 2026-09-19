use tauri::Manager;

// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

fn toggle_main_window(app: &tauri::AppHandle, args: &[String]) {
    if !args.iter().any(|arg| arg == "--toggle") {
        return;
    }
    if let Err(err) = toggle_main_window_inner(app) {
        eprintln!("single-instance: failed to toggle main window: {err}");
    }
}

fn toggle_main_window_inner(app: &tauri::AppHandle) -> tauri::Result<()> {
    let window = app
        .get_webview_window("main")
        .ok_or(tauri::Error::WebviewNotFound)?;
    if window.is_visible().unwrap_or(false) {
        window.hide()?;
    } else {
        window.show()?;
    }
    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_single_instance::init(move |app, args, _| {
            toggle_main_window(app, &args);
        }))
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
