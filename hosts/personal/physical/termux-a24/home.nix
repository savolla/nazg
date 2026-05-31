{
  config,
  pkgs,
  lib,
  dotfilesPath,
  self,
  nixpkgs-unstable,
  stable,
  unstable,
  ...
}:

{

  # custom modules from one-ring/modules/home-manager
  imports = [
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home = {
    stateVersion = "24.05"; # change this if you change the root flake.nix
    username = "savolla";
    # homeDirectory = "/home/savolla";
  };
  programs = {

    fish = {
      enable = true;
    };

    # pretty shell
    starship = {
      enable = true;
    };

    # manage environments depending on current directory (doom emacs dep)
    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true; # use gpg key as your ssh key
      pinentryPackage = pkgs.pinentry-curses;
    };

    tmux = {
      enable = true;
    };


    ssh = {
      enableAskPassword = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages = emacsPackages: [
        emacsPackages.pdf-tools
        emacsPackages.vterm
      ];
    };
  };

  # ~/.xprofile or ~/.profile
  home.sessionVariables = {
    # EXAMPLE = "value"
  };

  home.packages =
    with pkgs;
    [
      kitty # terminal emulator
      sesh # session manager for tmux
      fzf # fuzzy finder both for zshrc command history and tmux session finder and more

      # doom emacs dependencies
      emacs-lsp-booster # for eglot
      rust-analyzer # doom emacs dependency
      stylelint # doom emacs web module dep
      nodePackages.js-beautify # doom emacs web module dep
      rocmPackages.clang # for clang-format. doom emacs java and cc module dep
      glslang # for glslangValidator. doom emacs cc module dep
      nil # nix language server for doom emacs
      iconv # fix emacs cannot find home directory on non-nixo distros (ubuntu)
      fd # dependency for doom emacs and tmux session switcher
      nixfmt-rfc-style # doom emacs depENDENCY for nix buffer formatting

      # pyton modules
      python312Packages.pyflakes # doom emacs dependency
      python312Packages.pytest # doom emacs dependency
      python312Packages.nose2 # doom emacs dependency
      python312Packages.libtmux # manage tmux from python
      python312Packages.pyyaml # yaml library

      # general
      yazi # file manager that I use in neovim
      lua # dep for lua neovim
      pass # terminal passwork manager

      ssh-askpass-fullscreen

      direnv # execute commands once you enter into a directory
      fish # better zsh (make it your daily driver one day)
      fishPlugins.done # get notified when jobs finish

      # eglot lsp packages
      bash-language-server # lsp for bash
      ccls # c/cpp lsp
      clojure-lsp # self titled
      cmake-language-server # cmake lsp
      vscode-css-languageserver # css lsp
      tailwindcss-language-server # tailwind lsp
      docker-language-server # docker lsp
      elmPackages.elm-language-server # elm lsp
      fortls # fortran lsp
      gopls # go lsp (official)
      haskell-language-server # haskell lsp
      vscode-json-languageserver # json lsp
      jdt-language-server # java lsp
      typescript-language-server # js/ts lsp
      kotlin-language-server # kotlin lsp
      luajitPackages.lua-lsp # lua lsp
      marksman # markdown lsp
      ocamlPackages.ocaml-lsp # ocaml lsp
      pyright # python lsp
      rubyPackages.solargraph # ruby lsp
      metals # scala lsp
      texlab # LaTeX lsp
      yaml-language-server # yaml lsp
      zls # zig lsp


      ### devops/helm
      # helm # disabled bc it crashed on ubuntu. installed via snap instead
      helm-ls # helm language server
      helm-docs # auto generate helm chart documentation as markdown
      helm-dashboard # visualize your helm releases
      chart-testing # tool for testing helm charts
      nova # find outdated, deprecated helm charts on your cluster

      ## devops/networking
      inetutils # commonly used networking commands
      gping # graphical ping
      fping # send icmp echo probes to network hosts
      firejail # disable network for particular service
      asn # inspect network
      doggo # command line dns fo humans
      nmap # for testing open ports (I promise)

      ## devops/unikernels
      kraft # build unikernels
      ops # build nanos unikernels (for java apps)

      ## devops/git
      bfg-repo-cleaner # delete files from git history
      lazygit # git but lazy

      ## devops/misc
      php85Packages.composer # task runner
      jcli # manage jenkins from command line
      nixos-rebuild-ng # rebuild remote nixos machines from non-nixos hosts
      nixos-generators # create various images from nixos configuration files
      mkpasswd # gene rate hashes
      qemu # virtualization for good
      lazyssh # ssh but lazy
      jiratui # tui version of jira
      regex-tui # try regex interactively
      cloudlens # k9s but for cloud aws gcp (broken at the time)
      yq # jq on steroids
      atmos # create folder structure for terraform, opentofu, packer etc.
      # harlequin # database ide for terminal (disabled due to mysql adapter is not found on nix packages)
      lazysql # harlequin alternative
      uv # awesome pip replacement
      posting # tui api client
      toolong # inspect logs like a pro
      gonzo # log inspecting

      # dolphie # watch your mysql node (disabled due to nixpkgs don't have this yet)
      soapui # xml based apis
      k6 # test
      ggh # ssh session manager

      # arandr
      asciinema # record your terminal sessions
      asciinema-agg # asciinema gif generator
      asciinema-scenario # create videos from asciinema files

      # misc
      yt-dlp # to watch youtube from mpv
      wkhtmltopdf # convert webpages to pdf (for emacs note taking using pdf-tools and org-noter)
      buku # bookmark manager
      mpv # video player for life
      vim-full # for gvim to be installed (needed for qutebrowser default editor)
      atuin # shell history on steroids
      browsr # browse remote file systems
      bat # better cat
      tmuxp # declarative tmux sessions (disabled due to compilation errors..)
      tmux-xpanes # run multiple commands on multiple tmux panes at once
      tree # file trees
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # services
  services = {

  };
}
