{ pkgs, ... }:

let globalPackages = import ./global.nix { pkgs = pkgs; };
    platformPackages = import ./platform.nix { pkgs = pkgs; };
in {
  programs.home-manager.enable = true;
  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    packages = globalPackages ++ platformPackages;
    stateVersion = "21.11";
  };
}
