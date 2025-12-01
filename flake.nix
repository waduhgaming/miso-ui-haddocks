{

  inputs = {
    miso.url = "github:dmjio/miso";
    miso-ui.url = "github:haskell-miso/miso-ui";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    inputs.miso.inputs.flake-utils.lib.eachDefaultSystem (system:
      with (builtins.fromJSON (builtins.readFile ./flake.lock));
      let
        pkgs = import (nixpkgs) {
          inherit system;
        };
      in {
        devShells.default = inputs.miso.outputs.devShells.${system}.default;
        packages.default = pkgs.writeScriptBin "haddock" ''
          #!/usr/bin/env bash
          export PATH=$PATH:${pkgs.git}/bin:${pkgs.cabal-install}/bin
          git clone --depth=1 https://github.com/haskell-miso/miso-ui
          cd miso-ui
          git reset --hard ${nodes.miso-ui.locked.rev}
          cabal update
          cabal haddock-project --hoogle
        '';
      });
}


