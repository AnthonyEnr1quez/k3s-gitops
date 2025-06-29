{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        korb = pkgs.buildGoModule rec {
          pname = "korb";
          version = "2.3.2";
          src = pkgs.fetchFromGitHub {
            owner = "BeryJu";
            repo = "${pname}";
            rev = "v${version}";
            sha256 = "sha256-4f5Ii75Pc+88ONiEWAQG7A6NaKvQ5/1jqu3O0f7AaVI=";
          };
          doCheck = false;
          vendorHash = "sha256-ZXepf1gWdw9H/5XV3JPuyN8X9LG5C9La5oRLjtsRa0s=";
        };
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
            korb
          ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
