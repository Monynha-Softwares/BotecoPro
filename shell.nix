{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  flutter = pkgs.flutter;
in
pkgs.mkShell {
  packages = [
    flutter
    pkgs.cacert
    pkgs.git
    pkgs.python3
    pkgs.unzip
    pkgs.which
  ];

  shellHook = ''
    export FLUTTER_HOME=${flutter}
    export PATH=${flutter}/bin:${flutter}/bin/cache/dart-sdk/bin:$PATH
    flutter config --no-analytics --enable-web >/dev/null 2>&1 || true
  '';
}
