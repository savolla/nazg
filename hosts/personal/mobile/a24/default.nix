{ config, lib, pkgs, ... }:

{
  environment.packages = with pkgs; [
    # personal
    vim neovim tmux git zoxide fish direnv starship
    emacs-nox ncurses

    # essential
    procps killall diffutils findutils util-linux
    tzdata hostname man gnugrep gnupg gnused gnutar
    bzip2 gzip xz zip unzip
  ];

  environment.etcBackupExtension = ".bak";

  system.stateVersion = "24.05";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  time.timeZone = "Europe/Istanbul";
}
