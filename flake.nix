{
  description = "BotecoPro Flutter workspace";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            flutter
            python3
            pkg-config
            git
            which
            unzip
            curl
            openssl
          ];

          shellHook = ''
            export FLUTTER_ROOT=${pkgs.flutter}/share/flutter
            export PATH="$FLUTTER_ROOT/bin:$PATH"
            flutter config --enable-web >/dev/null 2>&1 || true
          '';
        };
      }
    );
}
