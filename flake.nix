{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      aarch64-darwin_pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      aarch64DarwinBuildInputs = with aarch64-darwin_pkgs; [ elixir_1_18 just yt-dlp ];
      aarch64-linux_pkgs = nixpkgs.legacyPackages.aarch64-linux;
      aarch64LinuxBuildInputs = with aarch64-linux_pkgs; [ elixir_1_18 just yt-dlp inotify-tools ];
      x86_64-linux_pkgs = nixpkgs.legacyPackages.x86_64-linux;
      x86_64LinuxBuildInputs = with x86_64-linux_pkgs; [ elixir_1_18 just yt-dlp inotify-tools ];

      buildShell = { pkgs, buildInputs }:
        pkgs.mkShell {
          buildInputs = buildInputs;
          shellHook = ''
            echo "Ready for dev!"
          '';
        };
    in
    {
      devShells.aarch64-darwin.default = buildShell { pkgs = aarch64-darwin_pkgs; buildInputs = aarch64DarwinBuildInputs; };
      devShells.aarch64-linux.default = buildShell { pkgs = aarch64-linux_pkgs; buildInputs = aarch64LinuxBuildInputs; };
      devShells.x86_64-linux.default = buildShell { pkgs = x86_64-linux_pkgs; buildInputs = x86_64LinuxBuildInputs; };

      formatter.aarch64-darwin = aarch64-darwin_pkgs.nixpkgs-fmt;
      formatter.aarch64-linux = aarch64-linux_pkgs.nixpkgs-fmt;
    }
  ;
}
