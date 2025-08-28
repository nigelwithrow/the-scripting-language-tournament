{
  outputs = { self, nixpkgs, ... }@inputs: {
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.hello;

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        ocaml
        just
      ];
      OCAMLLIB = "${nixpkgs.legacyPackages.x86_64-linux.ocaml}/lib/ocaml/";
      shellHook = ''
        echo "OCAMLLIB: $OCAMLLIB"
      '';
    };
  };
}
