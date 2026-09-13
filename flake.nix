{
  description = "Tauri v2 dev environment (React/Vue/Svelte + Rust stable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Tauri v2 на Linux требует WebKit2GTK 4.1 + libsoup 3 + gtk3.
        # На macOS/Windows эти либы не нужны — там devShell отдает только тулчейн.
        linuxLibs = with pkgs; [
          at-spi2-atk
          atk
          cairo
          dbus
          gdk-pixbuf
          glib
          glib-networking
          gtk3
          harfbuzz
          librsvg
          libsoup_3
          openssl
          pango
          webkitgtk_4_1
          # Трей-иконка (ayatana заменил старый appindicator в Tauri v2)
          libayatana-appindicator
        ];

        linuxOnly =
          if pkgs.stdenv.hostPlatform.isLinux then linuxLibs else [ ];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "tauri-v2-dev";

          nativeBuildInputs = with pkgs; [
            pkg-config
            gobject-introspection
            file
            curl
            wget
          ];

          buildInputs = with pkgs; [
            # Rust (stable из nixpkgs)
            cargo
            rustc
            rustfmt
            clippy
            rust-analyzer

            # Frontend (React/Vue/Svelte)
            nodejs_22
            corepack
            pnpm
          ] ++ linuxOnly;

          shellHook = ''
            # --- WebKit2GTK под NixOS: без этого черный экран / краш webview ---
            export WEBKIT_DISABLE_DMABUF_RENDERER=1

            # --- Rust: исходники для rust-analyzer ---
            export RUST_SRC_PATH="${pkgs.rustPlatform.rustLibSrc}"

            ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath linuxLibs}:$LD_LIBRARY_PATH"
              export PKG_CONFIG_PATH="${pkgs.lib.makeSearchPath "lib/pkgconfig" linuxLibs}:$PKG_CONFIG_PATH"
              export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
              export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules"
            ''}

            echo "Tauri v2 devShell"
            echo "  rustc $(rustc --version 2>/dev/null || echo missing) | cargo $(cargo --version 2>/dev/null || echo missing)"
            echo "  node $(node --version 2>/dev/null || echo missing) | pnpm $(pnpm --version 2>/dev/null || echo 'missing (включи: corepack enable)')"
            ${pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              echo "  webkit: $(pkg-config --modversion webkit2gtk-4.1 2>/dev/null || echo MISSING)"
            ''}
          '';
        };
      });
}
