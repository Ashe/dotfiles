inputs: {
  nix = import ./nix inputs;
  mesa-git = import ./mesa-git inputs;
  mullvad = import ./mullvad inputs;
  jellyfin = import ./jellyfin inputs;
  steam = import ./steam inputs;
}
