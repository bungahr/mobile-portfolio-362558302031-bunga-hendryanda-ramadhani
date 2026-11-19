{ pkgs ? import <nixpkgs> { } }:

let
  # Flutter 3.41 membawa Dart yang dibangun untuk macOS 14+.
  # Flutter 3.29.2 (Dart 3.7.2) masih dapat berjalan di macOS Ventura 13
  # dan tetap memenuhi batas proyek: Flutter >=3.24 serta Dart >=3.0.
  flutterSdk =
    if pkgs ? flutter329 then
      pkgs.flutter329
    else
      throw ''
        Nixpkgs ini tidak menyediakan flutter329.
        Gunakan channel Nixpkgs 25.05 atau versi Nixpkgs yang memuat Flutter 3.29.2.
      '';
in
pkgs.mkShellNoCC {
  name = "poliwangi-flutter-ventura";

  packages = [ flutterSdk ];

  # CocoaPods pada macOS memerlukan locale UTF-8.
  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.UTF-8";

  shellHook = ''
    # Dahulukan utilitas macOS asli. Dependensi Flutter dari Nix juga membawa
    # xcrun pengganti yang tidak boleh dipakai untuk build Apple platform.
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

    # Gunakan SDK Apple dari Xcode lokal. Ini mencegah SDK bawaan Nix
    # berbenturan dengan Xcode yang terpasang di macOS.
    if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
      export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
      export SDKROOT="$(/usr/bin/xcrun --sdk macosx --show-sdk-path 2>/dev/null || true)"
    fi

    # Pakai Android SDK milik Android Studio bila tersedia.
    if [ -z "''${ANDROID_SDK_ROOT:-}" ] && [ -d "$HOME/Library/Android/sdk" ]; then
      export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
    fi
    if [ -n "''${ANDROID_SDK_ROOT:-}" ]; then
      export ANDROID_HOME="$ANDROID_SDK_ROOT"
      export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
    fi

    # Flutter dapat memakai browser Chromium lain untuk target web.
    if [ ! -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ] \
      && [ -x "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" ]; then
      export CHROME_EXECUTABLE="/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    fi

    echo "Flutter shell aktif: $(flutter --version 2>/dev/null | /usr/bin/head -n 1)"
    echo "Jalankan: flutter doctor -v"
  '';
}
