{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system: let
        pkgs = (import nixpkgs { inherit system; });
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              ocaml
              opam
              dune_3
              pkg-config
              libffi

              ruby

              bun
              (pkgs.python3.withPackages (python-pkgs: [
                python-pkgs.pillow
                python-pkgs.numpy
              ]))
            ];
          };
          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
