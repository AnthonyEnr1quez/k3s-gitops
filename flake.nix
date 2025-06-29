{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            age
            fluxcd
            go-task
            kubectl
            kubernetes-helm
            k9s
            sops
            jq
            yq
            watch
            regctl
            cmctl
            restic
          ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
