{
  description = "The purely functional package manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
    in
    inputs.utils.lib.eachDefaultSystem (system: {
      bundlers = {
        default = inputs.self.bundlers.${system}.nix-bundle;
        nix-bundle =
          drv:
          let
            program = lib.getExe drv;
            nixpkgs = inputs.nixpkgs.legacyPackages.${system};
            nix-bundle = import inputs.self { inherit nixpkgs; };
            script = nixpkgs.writeScript "startup" ''
              #!/bin/sh
              .${nix-bundle.nix-user-chroot}/bin/nix-user-chroot -n ./nix -- ${program} "$@"
            '';
          in
          nix-bundle.makebootstrap {
            targets = [ script ];
            startup = ".${builtins.unsafeDiscardStringContext script} '\"$@\"'";
          };
      };
    });
}
