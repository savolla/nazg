{
  config,
  pkgs,
  lib,
  self,
  nixpkgs-unstable,
  stable,
  unstable,
  ...
}:

# for android emulator
let
  dwmFlexipatch = stable.stdenv.mkDerivation {
    pname = "dwm-flexipatch";
    version = "6.8";

    src = builtins.path {
      path = /home/kkoc/project/dev/nazg/tools/dwm-flexipatch;
      name = "dwm-flexipatch-src";
    };

    nativeBuildInputs = [
      stable.gnumake
      stable.gcc
      stable.pkg-config
    ];
    buildInputs = [
      stable.libx11
      stable.imlib2
      stable.libxcb
      stable.libxft
      stable.libxinerama
      stable.libxrandr
      stable.libxcursor
      stable.libxrender
    ];
    installPhase = ''
      mkdir -p $out/bin
      rm config.h patches.h
      make clean
      make
      cp dwm $out/bin/
    '';
  };

  mySlstatus = stable.stdenv.mkDerivation {
    pname = "mySlstatus";
    version = "1.0";
    src = builtins.path {
      path = /home/kkoc/project/dev/nazg/tools/slstatus;
      name = "slstatus-src";
    };
    nativeBuildInputs = [
      stable.gnumake
      stable.gcc
      stable.pkg-config
    ];
    buildInputs = [
      stable.libx11
      stable.libxft
      stable.libxinerama
      stable.libxrandr
      stable.libxcursor
      stable.imlib2
      stable.libsixel
      stable.fontconfig
      stable.freetype
    ];
    buildPhase = ''
      make clean
      make
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp slstatus $out/bin/
    '';
  };

  stFlexipatch = stable.stdenv.mkDerivation {
    pname = "st-flexipatch";
    version = "9.3";
    src = builtins.path {
      path = /home/kkoc/project/dev/nazg/tools/st-flexipatch;
      name = "st-flexipatch-src";
    };
    nativeBuildInputs = [
      stable.gnumake
      stable.gcc
      stable.pkg-config
    ];
    buildInputs = [
      stable.libx11
      stable.libxft
      stable.libxinerama
      stable.libxrandr
      stable.libxcursor
      stable.imlib2
      stable.libsixel
      stable.fontconfig
      stable.freetype
    ];
    buildPhase = ''
      make clean
      cp config.def.h config.h
      cp patches.def.h patches.h
      make
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp st $out/bin/
    '';
  };

  dmenuFlexipatch = stable.stdenv.mkDerivation {
    pname = "dmenu-flexipatch";
    version = "5.4";
    src = builtins.path {
      path = /home/kkoc/project/dev/nazg/tools/dmenu-flexipatch;
      name = "slock-flexipatch-src";
    };
    nativeBuildInputs = [
      stable.gnumake
      stable.pkg-config
    ];
    buildInputs = [
      stable.libx11
      stable.libxext
      stable.libxinerama
      stable.libxrandr
      stable.libxft
      stable.imlib2
      stable.libxscrnsaver
      stable.libxcrypt
      stable.pam
    ];
    buildPhase = ''
      make clean
      cp config.def.h config.h
      cp patches.def.h patches.h
      make
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp dmenu $out/bin/
      cp dmenu_path $out/bin/
      cp dmenu_run $out/bin/
    '';
    meta = {
      mainProgram = "dmenu";
    };
  };

  # slockFlexipatch = pkgs.stdenv.mkDerivation {
  #   pname = "slock-flexipatch";
  #   version = "1.6";
  #   src = builtins.path {
  #     path = /home/kkoc/project/dev/nazg/tools/slock-flexipatch;
  #     name = "slock-flexipatch-src";
  #   };
  #   nativeBuildInputs = [
  #     stable.gnumake
  #     stable.pkg-config
  #   ];
  #   buildInputs = [
  #     stable.libx11
  #     stable.libxext
  #     stable.libxinerama
  #     stable.libxrandr
  #     stable.imlib2
  #     stable.libxscrnsaver
  #     stable.libxcrypt
  #     stable.pam
  #   ];
  #   postPatch = ''
  #     sed -i 's/^LIBS =.*/LIBS = -lc -lcrypt -lX11 -lXext -lXrandr -lXinerama -lXss/' Makefile
  #   '';
  #   buildPhase = ''
  #     make clean
  #     cp config.def.h config.h
  #     cp patches.def.h patches.h
  #     make
  #   '';
  #   installPhase = ''
  #     mkdir -p $out/bin
  #     cp slock $out/bin/
  #   '';
  #   meta = {
  #     mainProgram = "slock";
  #   };
  # };
in
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
    stateVersion = "25.05"; # change this if you change the root flake.nix
    username = "kkoc";
    homeDirectory = "/home/kkoc";

    activation = {

      # fix gpu-screen-recorder-gtk's recording failure errors
      # using absolute paths is necessary for ubuntu commands
      gsrKmsServerCap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              GSR_KMS=$(readlink -f ${pkgs.gpu-screen-recorder}/bin/gsr-kms-server 2>/dev/null || true)
        if [ -n "$GSR_KMS" ]; then
          /usr/bin/sudo /usr/sbin/setcap cap_sys_admin+ep "$GSR_KMS" || true
        fi
      '';

      # stowDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #   echo "stowing dotfiles"
      #   ${pkgs.stow}/bin/stow -t $HOME -d "$HOME/project/dev/nazg/hosts/work/kartaca/laptop/fiat" dotfiles
      # '';

  #     linkSystemd = let
  #       inherit (lib) hm;
  #     in hm.dag.entryBefore [ "reloadSystemd" ] (''
  #       find $HOME/.config/systemd/user/ \
  #   -type l \
  #   -exec bash -c "readlink {} | grep -q $HOME/.nix-profile/share/systemd/user/" \; \
  #   -delete

  # find $HOME/.nix-profile/share/systemd/user/ \
  #   \( -type f -o -type l \) \
  #   -exec ln -s {} $HOME/.config/systemd/user/ \;
  #     '');

    };

  };
  programs = {
    eww = {
      enable = true;
      package = unstable.eww;
    };
    emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages = emacsPackages: [
        emacsPackages.pdf-tools
        emacsPackages.vterm
        emacsPackages.omnisharp # csharp lsp
      ];
    };

    rofi = {
      enable = true;
      theme = "gruvbox-dark-hard";
      font = "IosevkaTerm Nerd Font Mono 14";
      pass.enable = true;
      plugins = [
        pkgs.rofi-calc # awesome calculator
        pkgs.rofi-nerdy # search nerd-icons
        pkgs.rofi-emoji # search emoji
        pkgs.rofi-bluetooth
      ];
      extraConfig = {
        kb-remove-to-eol = "";
        kb-element-next = "";
        kb-accept-entry = "Tab";
        kb-row-down = "Control+j";
        kb-row-up = "Control+k";
      };
    };
  };

  # for android emulator
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.libnotify}/lib:${pkgs.libx11}/lib:${pkgs.dbus}/lib:\${LD_LIBRARY_PATH}";
  };

  # configure the NixGL targets
  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };

  home.packages =
    with pkgs;
    [

      unstable.pcsclite # for yubikey
      unstable.qutebrowser # qutebrowser with nixGL
      unstable.libnotify # for qutebrowser notification fix?
      unstable.oath-toolkit # get OTP from terminal
      unstable.conky # watch system state
      unstable.sassc # for eww widgets to compile

      unstable.charasay # cowsay good

      # slockFlexipatch # installed native slock on uubntu since nix version has problems with PAM
      stFlexipatch # custom st
      dwmFlexipatch # custom dwm
      mySlstatus # custom slstatus
      dmenuFlexipatch # custom dmenu

      stable.betterlockscreen
      unstable.vulkan-tools # display GPU info
      unstable.dunst # notifications
      stable.kitty # terminal emulator
      stable.autossh # watch and re-open ssh connections
      stable.sesh # session manager for tmux
      stable.fzf # fuzzy finder both for zshrc command history and tmux session finder and more
      stable.skim # faster fzf written in rust
      stable.gum # tasty interactive script creator
      stable.psmisc # optional dependency for fzf-tmux

      # doom emacs dependencies
      stable.emacs-lsp-booster # for eglot
      stable.rust-analyzer # doom emacs dependency
      stable.stylelint # doom emacs web module dep
      stable.js-beautify # doom emacs web module dep
      stable.rocmPackages.clang # for clang-format. doom emacs java and cc module dep
      stable.glslang # for glslangValidator. doom emacs cc module dep
      stable.nil # nix language server for doom emacs
      stable.iconv # fix emacs cannot find home directory on non-nixo distros (ubuntu)
      stable.fd # dependency for doom emacs and tmux session switcher
      stable.nixfmt # doom emacs depENDENCY for nix buffer formatting

      # python modules (standalone)
      stable.python312Packages.pyflakes # doom emacs dependency
      stable.python312Packages.pytest # doom emacs dependency
      stable.python312Packages.nose2 # doom emacs dependency
      stable.python312Packages.libtmux # manage tmux from python
      stable.python312Packages.pyyaml # yaml library

      # python modules (importable)
      (stable.python312.withPackages (ps: [
        ps.tldextract # qute-pass dependency
      ]))

      # general
      stable.weechat # irc stuff
      stable.yazi # file manager that I use in neovim
      stable.lua # dep for lua neovim
      stable.xbacklight # set brightness on laptop
      stable.pass # terminal passwork manager
      stable.gopass # pass on steroids

      stable.ssh-askpass-fullscreen

      stable.direnv # execute commands once you enter into a directory
      stable.fish # better zsh (make it your daily driver one day)
      stable.fishPlugins.done # get notified when jobs finish

      # devops
      ## devops/database
      dbeaver-bin
      stable.harlequin # connect to mysql, cassandra and such from tui
      mysql84
      unstable.sqlit-tui # better harlequin
      cassandra
      postgresql

      ## devops/monitoring
      prometheus
      glances
      # grafana (disabled due to home manager cannot run system services.. use nixos for this!)
      grafterm # grafana on terminal

      ## devops/docker
      # docker # can't work with home-manager since it requires systemd service
      # docker-buildx # newer build tool for docker (you need to fix the docker issue first)
      docker-compose
      ctop # watch container metrics
      lazydocker # manage your docker containers without friction
      dive # inspect docker images

      ## devops/kubernetes
      popeye # cluster scanner for misconfigurations
      kustomize # pure pain
      kubepug # before upgraing kubernetes
      kubetail # kubernetes logs
      litmus # kubernetes chaos engineering
      litmusctl # manager litrmux

      kube-capacity # get CPU, RAM, storage info of kubernetes nodes and pods
      cadvisor # kubernetes daemonset for resource usage monitoring
      kubectx # kubectl conetxt switcher + kubens
      kube-bench # security scanner for kubernetes
      kubectl # k8s api communicator
      k9s # tui kubernetes manager
      kubecolor # colorize kubectl output
      kubescape # scan security issues of kubernetes cluster
      rakkess # check what access do you have on a kubernetes cluster
      # NOTE: I disabled datree due to datree.io resolve errors. I installed it manually
      # datree # ensure K8s manifests and Helm charts follow best practices
      kubectl-doctor # get k8s diagnostics
      k8sgpt # llm for k8s
      dyff # better yaml file differ
      ktop # monitor kubernetes node usage
      kubeconform
      kubent # find deprecated api versions
      pluto # like kubent

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
      udiskie # mount disks without sudo

      ### kubectl plugins
      kubectl-graph
      kubectl-images
      kubectl-gadget
      kubectl-explore # fuzzy find in describe
      kubectl-evict-pod # good for testing pod distruption budgets
      kubectl-node-shell # exec into node
      kubectl-view-secret # decode kubernetes secret
      kubectl-convert # convert old deprecated api manifest to newer one

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

      # devops/cac
      # ansible # installed from apt for kubespray to work...
      salt
      terraform # manage infra as code
      terraform-lsp # lsp for emacs terraform mode
      terraformer # reverse terraform!
      tftui # interractive terraform state browser

      # arandr
      asciinema # record your terminal sessions
      asciinema-agg # asciinema gif generator
      asciinema-scenario # create videos from asciinema files

      # misc
      fuse # some appimages require it
      # gccgo # gcc for go (I forgot why I needed it..)
      xcolor
      yt-dlp # to watch youtube from mpv
      wkhtmltopdf # convert webpages to pdf (for emacs note taking using pdf-tools and org-noter)
      buku # bookmark manager
      mpv # video player for life
      vim-full # for gvim to be installed (needed for qutebrowser default editor)
      pcmanfm # lightweight file manager
      astroterm # watch the sky from your terminal
      atuin # shell history on steroids
      bagels # expanse tracker in tui
      bluetui # tui bluetooth manager
      browsr # browse remote file systems
      caligula # disk imaging (tui balena-etcher/rufus)
      carbon-now-cli # generate images from your code
      cariddi # crawl urls. good for discovery
      dstp # run networking tests to your site
      castero # podcasts in tui
      chawan # tui web browser
      circumflex # hackernews in your browser
      cotp # tui otp
      cpufetch # get cpu info fast
      croc # easily send files between hosts
      csvlens # pretty print your csv files
      duf # free alternative
      fclones # remove file duplicates
      arandr # manage multiple monitors with gui
      bat # better cat
      jamesdsp # better music listening experience
      newsboat # rss viewer
      unstable.tmux
      tmuxp # declarative tmux sessions (disabled due to compilation errors..)
      tmux-xpanes # run multiple commands on multiple tmux panes at once
      tree # file trees

      # zsh
      zsh
      zsh-autosuggestions
      zsh-fast-syntax-highlighting
      zsh-abbr # abbreviations just like fish

      # personal/music
      timidity # play midi files usin mpd
      rmpc
      cava # auto visualizer
      mpc # control mpd

      # personal/misc
      remmina # remote desktop for openshift
      vpnc-scripts # for vpn
      opencode # claude-code open source alt.
      libva-utils # list VAAPI capabie devices on your system (needed for optimizing sunshine)
      tiddlywiki
      rust-petname # generate random names (useful for server hostnames)
      syncthing
      isync # for mbsync
      mu # for emacs mu4e to work
      delta # bat like diff
      libx11 # for suckless tools to be compiled
      zoxide # cd on steroids
      translate-shell # needed for using rofi as translate engine
      virt-viewer # display spice vms from proxmox
      moonlight-qt # sunshine client for superior RDP
      unstable.sunshine # better rdp
      terminal-parrot # wow
      p7zip # 7z
      gvfs
      at # timer for linux
      unstable.urlencode # decode url-encoded strings
      libmtp
      mtpfs # mount android filesystem
      nautilus # just in case file manager
      wtfutil # build customized tui dashboards
      qalculate-gtk # dependency for rofi-calc
      xdotool # autotype things (requirement for legolas script)
      libqalculate # awesome calculator qalculate
      libxml2 # for xmllint to installed (for soap cli)
      xsel # clipboard for xorg
      screenkey # display keys pressed
      gpu-screen-recorder-gtk # screen recorder using gpu with gui
      gpu-screen-recorder # screen recorder using gpu
      # go-jira # command line jira for my rofi script
      # skim # skim instead of fzf
      hexyl # command line hex viewer (for ranger and yazi)
      zathura # pdf reader
      serpl # find and replace
      unp # archive agnostic uncompressor
      xsct # adjust screen temperature
      xournalpp # draw shapes
      neovim # better vim
      iamb # matrix client for terminal
      gdu # fancy ncdu
      stow # manage dotfiles
      scrcpy # control your android from your pc
      nchat # tui whatsapp/telegram
      mapscii # google maps in tui
      tlock # 2FA tui
      profanity # tui xmpp
      insomnia # rest client
      slack-term # tui slack
      nethack # best roguelike
      browsh # terminal browser that rocks
      firefox # okay browser
      mcfly # super ctrl+r
      mcfly-fzf # super ctrl+r with fzf (you must install mcfly first)
      # mynav # better session management on top of tmux (not in nixpkgs)
      # sshm # better than lazyssh (not in nixpkgs)
      termscp # use SCP/SFTP/FTP/S3/SMB from tui
      # carbonyl # chromium in your terminal (seriously) (not in nixpkgs)
      # fancy-cat # tui pdf reader (broken)
      invidtui # youtube in tui

      libreoffice
      picom
      reader # render curl output better
      below # what's eating my ram right now?!

      banner
      # testing
      jmeter # testing framework
      pulseaudioFull

      # programming/languages
      go

    ]
    ++ (with stable; [
      clickhouse
    ]);

  # nixpkgs.config.allowBroken = true;

  # nixpkgs = {
  #   config = {
  #     allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #       "terraform"
  #       "slack"
  #       "lens" # kubernetes ide
  #     ];
  #   };
  # };

  # fix most of the notification problems
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
    # Add this if not already present:
    xdgOpenUsePortal = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # services
  services = {

    mpd = {
      enable = true;
      musicDirectory = "/home/kkoc/resource/music";
      playlistDirectory = "/home/kkoc/.config/mpd/playlists";
      dbFile = "/home/kkoc/.config/mpd/database";
      network = {
        port = 6600;
      };
      extraConfig = ''
        audio_output {
          type        "pulse"
          name        "PulseAudio Output"
        }

        audio_output {
          type        "fifo"
          name        "rmpc-cava"
          path        "/tmp/mpd.fifo"
          format      "44100:16:2"
        }
      '';
    };
  };
}
