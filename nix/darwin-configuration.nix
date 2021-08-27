{ pkgs, ... }:

{
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = false;
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
  };
}
