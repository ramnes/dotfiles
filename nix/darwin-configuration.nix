{ pkgs, ... }:

{
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
  };
}
