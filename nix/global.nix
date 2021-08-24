{ pkgs }:

with pkgs; [
  bash-completion
  bashInteractive
  coreutils
  curl
  emacs-nox
  gh
  gimp
  go
  htop
  jq
  kubectl
  mosh
  python39
  python39.pkgs.pip
  python39.pkgs.setuptools
  python39.pkgs.virtualenv
  shellcheck
  tree
  tmux
  watch
  wget
  yq
]
