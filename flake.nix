{
  description = "Boteco PRO Flutter web environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        flutter = pkgs.flutter;
      in {
        devShells.default = pkgs.mkShell {
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
        };
      });
}
