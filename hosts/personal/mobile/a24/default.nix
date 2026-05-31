{ config, lib, pkgs, ... }:

{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim # or some other editor, e.g. nano or neovim
    neovim
    tmux

    # Some common stuff that people expect to have
    procps
    killall
    diffutils
    findutils
    util-linux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
    git
  ];

  # backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # read the changelog before changing this value
  system.stateVersion = "24.05";

  # set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # set your time zone
  time.timeZone = "Europe/Istanbul";

  programs = {

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true; # use gpg key as your ssh key
      pinentryPackage = pkgs.pinentry-curses;
    };

    tmux = {
      enable = true;
    };

    ssh = {
      enable = true;
    };

    fish = {
      enable = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    # pretty shell
    starship = {
      enable = true;
    };
  };
}
