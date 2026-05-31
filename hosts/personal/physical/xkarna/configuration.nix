{
  config,
  pkgs,
  lib,
  stable,
  unstable,
  ...
}:

let
  # eilmeldung-src = builtins.fetchTarball {
  #   url = "https://github.com/christo-auer/eilmeldung/archive/refs/heads/main.tar.gz";
  #   sha256 = "sha256:10d9qf7kxsyp2irjxpn3y1j7nbxm40cphb2700gqman576rv6fs7";

  # };
  # eilmeldung = pkgs.callPackage "${eilmeldung-src}/nix/package.nix" { };

  # noctalia-shell-src = builtins.fetchTarball {
  #   url = "https://github.com/noctalia-dev/noctalia-shell/archive/refs/tags/v4.5.0.tar.gz";
  #   sha256 = "sha256:1syqsml49jfjpngi7b099jcggp66lrls0ha6w5daqd5xhd2z94v3";

  # };
  # noctalia-shell = pkgs.callPackage "${noctalia-shell-src}/nix/package.nix" { };

  # wk-src = builtins.fetchTarball {
  #   url = "https://github.com/3L0C/wk/archive/refs/tags/v0.3.1.tar.gz";
  #   sha256 = "sha256:1blxk9388r65lw0wbcjw50p3nkf8x63p2iaqm1y3qpj280zs0jki";
  # };
  # wk = pkgs.callPackage "${wk-src}/default.nix" {};

  dwmFlexipatch = pkgs.stdenv.mkDerivation {
    pname = "dwm-flexipatch";
    version = "6.8";

    src = builtins.path {
      path = /home/savolla/project/repos/one-ring/tools/suckless/dwm-flexipatch;
      name = "dwm-flexipatch-src";
    };

    nativeBuildInputs = [
      pkgs.gnumake
      pkgs.gcc
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.libx11
      pkgs.imlib2
      pkgs.libxcb
      pkgs.libxft
      pkgs.libxinerama
      pkgs.libxrandr
      pkgs.libxcursor
      pkgs.libxrender
    ];
    installPhase = ''
      mkdir -p $out/bin
      rm config.h patches.h
      make clean
      make
      cp dwm $out/bin/
    '';
  };

  mySlstatus = pkgs.stdenv.mkDerivation {
    pname = "mySlstatus";
    version = "1.0";
    src = builtins.path {
      path = /home/savolla/project/repos/one-ring/tools/suckless/slstatus;
      name = "slstatus-src";
    };
    nativeBuildInputs = [
      pkgs.gnumake
      pkgs.gcc
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.libx11
      pkgs.libxft
      pkgs.libxinerama
      pkgs.libxrandr
      pkgs.libxcursor
      pkgs.imlib2
      pkgs.libsixel
      pkgs.fontconfig
      pkgs.freetype
    ];
    buildPhase = ''
      make
    '';
    installPhase = ''
        mkdir -p $out/bin
      cp slstatus $out/bin/
    '';
  };

  stFlexipatch = pkgs.stdenv.mkDerivation {
    pname = "st-flexipatch";
    version = "9.3";
    src = builtins.path {
      path = /home/savolla/project/repos/one-ring/tools/suckless/st-flexipatch;
      name = "st-flexipatch-src";
    };
    nativeBuildInputs = [
      pkgs.gnumake
      pkgs.gcc
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.libx11
      pkgs.libxft
      pkgs.libxinerama
      pkgs.libxrandr
      pkgs.libxcursor
      pkgs.imlib2
      pkgs.libsixel
      pkgs.fontconfig
      pkgs.freetype
    ];
    buildPhase = ''
        cp config.def.h config.h
      cp patches.def.h patches.h
      make
    '';
    installPhase = ''
        mkdir -p $out/bin
      cp st $out/bin/
    '';
  };

  slockFlexipatch = pkgs.stdenv.mkDerivation {
    pname = "slock-flexipatch";
    version = "1.6";
    src = builtins.path {
      path = /home/savolla/project/repos/one-ring/tools/suckless/slock-flexipatch;
      name = "slock-flexipatch-src";
    };
    nativeBuildInputs = [
      pkgs.gnumake
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.libX11
      pkgs.libXext
      pkgs.libXinerama
      pkgs.libXrandr
      pkgs.imlib2
      pkgs.libXScrnSaver
      pkgs.libxcrypt
      pkgs.pam
    ];
    postPatch = ''
      sed -i 's/^LIBS =.*/LIBS = -lc -lcrypt -lX11 -lXext -lXrandr -lXinerama -lXss/' Makefile
    '';
    buildPhase = ''
        cp config.def.h config.h
      cp patches.def.h patches.h
      make
    '';
    installPhase = ''
        mkdir -p $out/bin
      cp slock $out/bin/
    '';
    meta = {
      mainProgram = "slock";
    };
  };

  dmenuFlexipatch = pkgs.stdenv.mkDerivation {
    pname = "dmenu-flexipatch";
    version = "5.4";
    src = builtins.path {
      path = /home/savolla/project/repos/one-ring/tools/suckless/dmenu-flexipatch;
      name = "slock-flexipatch-src";
    };
    nativeBuildInputs = [
      pkgs.gnumake
      pkgs.pkg-config
    ];
    buildInputs = [
      pkgs.libX11
      pkgs.libXext
      pkgs.libXinerama
      pkgs.libXrandr
      pkgs.libxft
      pkgs.imlib2
      pkgs.libXScrnSaver
      pkgs.libxcrypt
      pkgs.pam
    ];
    buildPhase = ''
        cp config.def.h config.h
      cp patches.def.h patches.h
      make
    '';
    installPhase = ''
        mkdir -p $out/bin
      cp dmenu $out/bin/
    '';
    meta = {
      mainProgram = "dmenu";
    };
  };

in

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.initrd.systemd.enable = true; # ask password for encrypted LUKS devices (graphically)

  boot = {
    plymouth = {
      enable = true;
      theme = "abstract_ring";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "abstract_ring" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
      "resume=UUID=2954f857-a502-4b6c-837c-4250349bd469" # swap UUID, not LUKS UUID (for hibernation to work)

      "mitigations=off" # leave cpu alone! this is not a server macnine (spectre/meltdown vunls etc.)

      # fix suspend problems
      "mem_sleep_default=deep"
      "amdgpu.sg_display=0"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

  };

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_zen; # this kernel is the only one that sees my eno1 ethernet interface on gmktek g10
  # boot.kernelPackages = pkgs.linuxPackages-rt_latest; # linux realtime kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest; # fix type-c and eno1 interfaces on nix machine GMKTek Nucbox G10
  # boot.kernelPackages = pkgs.linuxPackages; # LTS (for stability)

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # nix installation ssd 512GB
  boot.initrd.luks.devices."luks-51ca4097-c9b8-4d69-8f65-b62f20f910d0".device =
    "/dev/disk/by-uuid/51ca4097-c9b8-4d69-8f65-b62f20f910d0";

  # auto mount my SAMSUNG EVO 990 NVME that contains my home folder /home/savolla
  boot.initrd.luks.devices."savolla".device =
    "/dev/disk/by-uuid/ad7af5f0-e3a1-491e-ac65-4d366745b8f1";
  fileSystems."/home/savolla" = {
    device = "/dev/disk/by-uuid/9afcaaf0-49dd-4c51-bea4-9415c4c4292a";
    fsType = "ext4";
  };

  # encrypted swap partition for hibernation to work
  boot.resumeDevice = "/dev/disk/by-uuid/2954f857-a502-4b6c-837c-4250349bd469";

  # boot.initrd.kernelModules = [ "amdgpu" ]; # make the kernel use the correct driver early. fix those blury boot messages and hibernation problems

  # improve performance for heavy tab usage in browsers (qutebrowser setting)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;  # up to ~5.8GB of compressed swap from your 11.6GB RAM
  };

  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    networkmanager.dns = "none"; # for dnscrypt
    hostName = "xkarna";
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    networkmanager = {
      enable = true;
      # connectionConfig = {
      #   "Wired connection 2" = {
      #     ipv4.route-metric = 100;
      #     ipv6.route-metric = 100;
      #   };
      #
      #   "Wired connection 1" = {
      #     ipv4.route-metric = 500;
      #     ipv6.route-metric = 500;
      #   };
      # };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "trq";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    motd = "";
    motdFile = null; # disable MotD globally for all users

    users = {
      savolla = {
        isNormalUser = true;
        description = "savolla";
        extraGroups = [
          "networkmanager" # wifi etc.
          "wheel" # sudo
          "input" # xorg
          "video" # xorg
          "audio" # pipewire
          "libvirtd" # virtualization
          "docker" # run docker commands withour sudo
          "podman" # run podman commmands without sudo
          "vboxusers" # vbox guest additions and clipboard share
          "kvm" # android emulation with kvm (faster)
          "adbusers" # interact with android and emulators with adb
          "systemd-journal" # watch system logs with `journalctl -f` witout sudo password
        ];

        shell = pkgs.fish;
      };
    };
  };

  # Allow unfree packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };

    overlays = [
      (self: super: {
        mpv = super.mpv.override {
          scripts = [
            self.mpvScripts.quality-menu
            self.mpvScripts.quack
          ];
        };
        weechat = super.weechat.override {
          configure =
            { availablePlugins, ... }:
            {
              scripts = with super.weechatScripts; [
                url_hint
                colorize_nicks
                weechat-notify-send
              ];
            };
        };

        # REASON: while on unstable channel (2026-05-28) openldap was
        # failing to build. it was lutris dependency. maybe remove later?
        openldap = super.openldap.overrideAttrs (_: {
          doCheck = false;
        });

      })
    ];
  };

  qt.style = "adwaita-dark";

  environment = {

    etc."issue".text = ""; # clear /etc/issue for disabling messages in Motd

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/savolla/.steam/root/compatibilitytools.d";
      GTK_THEME = "Adwaita:dark";
    };

    systemPackages = with pkgs; [

      # custom packages
      mySlstatus
      dwmFlexipatch
      stFlexipatch
      slockFlexipatch
      dmenuFlexipatch

      # nixos-unstable packages
      # unstable.emacs-pgtk # transparency works in wayland
      unstable.OVMFFull
      unstable.pegasus-frontend # retroarch and lutris frontend
      unstable.skyscraper # scrape game metadata (dep for my pegasus-frontend + retararch setup)
      unstable.adw-gtk3 # for adwaita-dark theme
      unstable.adwaita-icon-theme # pretty icons (objective)
      unstable.adwaita-qt # make qt applications use dark theme
      unstable.alsa-scarlett-gui # focusrite scarlett solo gui
      unstable.alsa-utils # for amixer and and setting volume via scripts and terminal
      unstable.amdctl # set options for your amd cpu
      unstable.android-tools # for adb
      unstable.ansible # cac
      unstable.antimicrox # map ps4 controller keys to nintendo switch and others
      unstable.appimage-run # run appimages on nixos
      unstable.arandr # manage multiple monitors with gui
      unstable.arp-scan-rs # scan local network
      unstable.asciinema # record your terminal sessions
      unstable.asciinema-agg # asciinema gif generator
      unstable.asciinema-scenario # create videos from asciinema files
      unstable.asn # inspect network
      unstable.aspell # for flyspell package to work in emacs
      unstable.aspellDicts.en # spellcheck for Turkish lang (emacs)
      unstable.aspellDicts.tr # spellcheck for Turkish lang (emacs)
      unstable.astroterm # watch the sky from your terminal
      unstable.atmos # create folder structure for terraform, opentofu, packer etc.
      unstable.atuin # shell history on steroids
      unstable.audit # for crosstool-ng dep
      unstable.autoconf # for crosstool-ng dep
      unstable.automake # for crosstool-ng dep
      unstable.autossh # watch and re-open ssh connections
      unstable.awscli2 # aws cli tools
      unstable.bagels # expanse tracker in tui
      unstable.banner
      unstable.bat # better cat
      unstable.below # what's eating my ram right now?!
      unstable.bfg-repo-cleaner # delete files from git history
      unstable.binwalk # check files
      unstable.bison
      unstable.black # doom emacs (python-mode code formatter)
      unstable.bleachbit # system cleanup
      unstable.blender # 3d design
      unstable.bluetui # tui bluetooth manager
      unstable.bottles-unwrapped # powerful wine thing
      unstable.brightnessctl # set brightness (newer)
      unstable.browsr # browse remote file systems
      unstable.btop # better system monitor
      unstable.btrfs-progs # you need this for nixos os-prober detect other oses like fedora which uses btrfs by default
      unstable.bundletool # convert .abb to .apk
      unstable.busybox # bunch of utilities (need)
      unstable.cabextract # installed this to install Age of Empires Online (prefix that was created by Kron4ek)
      unstable.cadvisor # kubernetes daemonset for resource usage monitoring
      unstable.calf # high quality music production plugins and vsts
      unstable.caligula # disk imaging (tui balena-etcher/rufus)
      unstable.camunda-modeler # business modeling tool
      unstable.carbon-now-cli # generate images from your code
      unstable.cargo
      unstable.cariddi # crawl urls. good for discovery
      unstable.cassandra
      unstable.castero # podcasts in tui
      unstable.cava # auto visualizer
      unstable.ccls
      unstable.chart-testing # tool for testing helm charts
      unstable.chawan # tui web browser
      unstable.chromium # ungoogled chrome (needed for react-native debugger)
      unstable.circumflex # hackernews in your browser
      unstable.clang
      unstable.clang-tools
      unstable.cloudlens # k9s but for cloud aws gcp (broken at the time)
      unstable.cmake # installed for vterm to compile
      unstable.colordiff # to display colored output (installed for tshark)
      unstable.conky # display vital information on every workspace
      unstable.cotp # tui otp
      unstable.cowsay
      unstable.cpufetch # get cpu info fast
      unstable.cpuinfo
      unstable.crc # locally install openshift
      unstable.croc # easily send files between hosts
      unstable.crosspipe # modern jack ui (using this instead helvum)
      unstable.cryptomator # access encrypted vaults
      unstable.cryptomator-cli # access encrypted vaults ( not in stable channel yet )
      unstable.csvlens # pretty print your csv files
      unstable.ctop # watch container metrics
      unstable.czkawka # gui for finding duplicate files
      unstable.datree # ensure K8s manifests and Helm charts follow best practices
      unstable.dbeaver-bin # database awesomeness
      unstable.direnv # execute commands once you enter into a directory
      unstable.distrobox # run other distrox using docker
      unstable.dive # inspect docker images
      unstable.dmg2img # convert apple's disk images to .img files. (needed for installing hackintoch on qemu)
      unstable.docker
      unstable.docker-buildx
      unstable.docker-compose # installing self-hosting services via docker is better thank using nixos services (more portable and control data more easily)
      unstable.dockfmt # doom emacs (docker file formatting)
      unstable.doggo # command line dns fo humans
      unstable.dragonfly-reverb
      unstable.drawio # draw rldb, uml diagrams etc. (could not compile on nixos-unstagble)
      unstable.dstp # run networking tests to your site
      unstable.dua # better ncdu
      unstable.duf # free alternative
      unstable.dunst # notification daemon
      unstable.dyff # better yaml file differ
      unstable.eas-cli # build expo apk and dmg
      unstable.eclipses.eclipse-java # for camunda and spring boot
      unstable.edk2 # for osx-kvm (tianocore uefi)
      unstable.edk2-uefi-shell # for osx-kvm (tianocore uefi)
      unstable.elephant # wayland stuff (not yet in stable)
      unstable.emacs-gtk # true transparency works with this one on xorg
      unstable.emacs-lsp-booster # for faster lsp in emacs (only works in eglot atm)
      unstable.emacsPackages.mu4e
      unstable.emacsPackages.websocket # emacs org-roam-ui dependency
      unstable.epub-thumbnailer # for displaying epub covers (dirvish)
      unstable.eq10q
      unstable.eza # ls alternative
      unstable.fastfetch # system info
      unstable.faust # dsp language
      unstable.faust2jaqt # faust dependency
      unstable.fclones # remove file duplicates
      unstable.fd # dependency for doom emacs and tmux session switcher
      unstable.feh # set wallpapers
      unstable.ffmpeg-full # needed for ncmpcpp cover art display and bunch of other things
      unstable.ffmpegthumbnailer # doom emacs dirvish dep
      unstable.fftw # fastest fourier transform for ncmpcpp
      unstable.figma-linux # frontend development
      unstable.fil-plugins
      unstable.file
      unstable.firefox # normal browser
      unstable.firefox-devedition # bin edition because nix tries to compile `firefox-devedition` and fails
      unstable.firejail # disable network for particular service
      unstable.fish # better zsh (make it your daily driver one day)
      unstable.flameshot # screenshot utility for xorg
      unstable.flex # for crosstool-ng dep
      unstable.fortune
      unstable.fping # send icmp echo probes to network hosts
      unstable.freetube # youtube blocks my video stream after 1 minute when I use ublock origin
      unstable.freetype # to be able to compile suckless utils
      unstable.fuse # some appimages require it
      unstable.fuzzel # application launcher
      unstable.fzf # fuzzy finder both for zshrc command history and tmux session finder and more
      unstable.gajim # xmpp client for linux
      unstable.gallery-dl
      unstable.gammastep # redshift/sct alternative for wayland
      unstable.gcc # for crosstool-ng dep
      unstable.gcolor3 # color palettes for web dev
      unstable.gdu # scan storage for size
      unstable.genymotion # for testing react native apps in emulators
      unstable.geonkick
      unstable.ggh # ssh session manager
      unstable.ghostty
      unstable.gimp-with-plugins # open source photoshop
      unstable.git # version control
      unstable.glslang # for glslangValidator. doom emacs cc module dep
      unstable.gnumake # make for all
      unstable.gnupg # encryption and stuff
      unstable.go
      unstable.godot_4 # 3d and 2d game engine
      unstable.gonzo # log inspecting
      unstable.gowall # change colorschemes of any wallpaper
      unstable.gparted
      unstable.gperftools # improve memory allocation performance for CPU (need for ai apps use CPU instead f GPU)
      unstable.gping # graphical ping
      unstable.gpu-screen-recorder # noctalia's plugin needs this (also a great solution for screen recording)
      unstable.gpu-screen-recorder-gtk # noctalia's plugin needs this (also a great solution for screen recording)
      unstable.gpu-viewer # Front-end to glxinfo, vulkaninfo, clinfo and es2_info
      unstable.grafana
      unstable.grafterm # grafana on terminal
      unstable.graphviz # org-mode graph generation dependency
      unstable.grim # screenshot utility
      unstable.gsmartcontrol # check harddrive health
      unstable.gtk3 # emacs requires this
      unstable.guestfs-tools # bunch of tools with virt-sparsify
      unstable.guitarix # a virtual guitar amplifier for Linux running with JACK
      unstable.gum # tasty interactive script creator
      unstable.gvfs
      unstable.gxplugins-lv2 # guitar amps, pedals, effects
      unstable.harlequin # database ide for terminal
      unstable.hdparm # remove disks safely from terminal
      unstable.helm # disabled bc it crashed on ubuntu. installed via snap instead
      unstable.helm-dashboard # visualize your helm releases
      unstable.helm-docs # auto generate helm chart documentation as markdown
      unstable.helm-ls # helm language server
      unstable.help2man # for crosstool-ng dep
      unstable.html-tidy
      unstable.htop
      unstable.iaito
      unstable.iamb # matrix client for terminal
      unstable.iconv # fix emacs cannot find home directory on non-nixo distros (ubuntu)
      unstable.imagemagick # for mp4 to gif conversion and other stuff
      unstable.inetutils # for whois command
      unstable.inkscape-with-extensions # svg and logo design
      unstable.input-remapper # map mouse movement to joystick. (play ryujinx games with mouse and keyboard)
      unstable.insomnia # make api calls easily (postman alternative)
      unstable.invidtui # youtube in tui
      unstable.inxi # get hardware information
      unstable.iptraf-ng # watch network traffix in tui
      unstable.ispell # emacs spell checking dep
      unstable.isync
      unstable.iw # needed for slstatus
      unstable.jamesdsp # equalizer for pipewire
      unstable.jcli # manage jenkins from command line
      unstable.jdk # for JAVA installation. needed for android sdk and other apps (this installs the latest version of jdk)
      unstable.jira-cli-go # command line jira for my rofi script
      unstable.jiratui # tui version of jira
      unstable.jmeter # testing framework
      unstable.jpegoptim # optimize jpeg
      unstable.jq # needed for my adaptive bluelight filter adjuster
      unstable.js-beautify # doom emacs web module dep
      unstable.jsbeautifier
      unstable.k6 # test
      unstable.k8sgpt # llm for k8s
      unstable.k9s # tui kubernetes manager
      unstable.kazam # record screen
      unstable.kdePackages.isoimagewriter # balena etcher alternative
      unstable.kdePackages.kdenlive # open source video editing software
      unstable.keepassxc # password manager
      unstable.kitty # fallback terminal
      unstable.klick # cli metronom
      unstable.koreader # awesome book reader
      unstable.kraft # build unikernels
      unstable.krita # digital art in linux? also comfyui integration using comfyui plugins
      unstable.ktop # monitor kubernetes node usage
      unstable.kube-bench # security scanner for kubernetes
      unstable.kube-capacity # get CPU, RAM, storage info of kubernetes nodes and pods
      unstable.kubecolor # colorize kubectl output
      unstable.kubeconform
      unstable.kubectl # k8s api communicator
      unstable.kubectl-convert # convert old deprecated api manifest to newer one
      unstable.kubectl-doctor # get k8s diagnostics
      unstable.kubectl-evict-pod # good for testing pod distruption budgets
      unstable.kubectl-explore # fuzzy find in describe
      unstable.kubectl-gadget
      unstable.kubectl-graph
      unstable.kubectl-images
      unstable.kubectl-node-shell # exec into node
      unstable.kubectl-view-secret # decode kubernetes secret
      unstable.kubectx # kubectl conetxt switcher + kubens
      unstable.kubent # find deprecated api versions
      unstable.kubepug # before upgraing kubernetes
      unstable.kubernetes-helm # kubernetes package manager
      unstable.kubescape # scan security issues of kubernetes cluster
      unstable.kubetail # kubernetes logs
      unstable.kustomize # pure pain
      unstable.latexminted # just in case
      unstable.lazydocker # manage your docker containers without friction
      unstable.lazygit # git but lazy
      unstable.lazysql # harlequin alternative
      unstable.lazyssh # ssh but lazy
      unstable.lens # kubernetes ide
      unstable.libcaca # ascii art viewer
      unstable.libgen-cli # download books from libgen
      unstable.libmtp
      unstable.libnotify # dunst dep
      unstable.libqalculate # awesome calculator qalculate
      unstable.libre-baskerville # above font does not work
      unstable.librewolf # paranoid browser
      unstable.libtool # installed for compiling vterm
      unstable.libwebp # convert images to webp
      unstable.libxcb # fix steam "glXChooseVisual" error
      unstable.libxml2 # for xmllint to installed (for soap cli)
      unstable.libxshmfence # appimage-run requires it for some appimages like Mechvibes
      unstable.lilypond-unstable-with-fonts # music notation (for doom emacs org-mode)
      unstable.litmus # kubernetes chaos engineering
      unstable.litmusctl # manager litrmux
      unstable.localstack # local aws
      unstable.logseq # note taking tool
      unstable.lolcat
      unstable.love # awesome 2d game engine written in lua
      unstable.lsp-plugins # collection of open-source audio plugins
      unstable.lua # dep for lua neovim
      unstable.lxappearance # style gtk applications
      unstable.lxsession # session manager
      unstable.mako # wayland notification daemon (for niri)
      unstable.mangohud # display fps, temperature etc.
      unstable.mapscii # google maps in tui
      unstable.mcfly # super ctrl+r
      unstable.mcfly-fzf # super ctrl+r with fzf (you must install mcfly first)
      unstable.mediainfo # for displaying audio metadata (dirvish)
      unstable.mermaid-cli # for org-babel mermaid diagrams support (doom emacs)
      unstable.mkpasswd # gene rate hashes
      unstable.moonlight-qt # sunshine client for superior RDP
      unstable.mp3blaster # auto tag mp3 files using mp3tag tool
      unstable.mpc # control mpd from terminal
      unstable.mpd # music player daemon
      unstable.mpv # awesome media player (overlayed!)
      unstable.msmtp
      unstable.mtpfs # mount android filesystem
      unstable.mu
      unstable.musescore # sheet happens
      unstable.mutagen # better syncthing
      unstable.mysql84
      unstable.nautilus # just in case file manager
      unstable.nchat # tui whatsapp/telegram
      unstable.ncmpcpp # custom ncmpcpp with visualizer. see let/in on top
      unstable.ncurses
      unstable.neovim # better vim
      unstable.nethack # best roguelike
      unstable.neural-amp-modeler-lv2 # you'll download guitar tones for this below
      unstable.newsboat # rss/atom reader
      unstable.nicotine-plus # download music with ease
      unstable.nil # nix language server for doom emacs
      unstable.nixfmt # doom emacs dependency for nix buffer formatting
      unstable.nixos-container # create very lightweight declarative LXC nixos based containers
      unstable.nixos-generators # generate various images from nixos config (qcow2)
      unstable.nixos-rebuild-ng # rebuild remote nixos machines from non-nixos hosts
      unstable.nmap # for testing open ports (I promise)
      unstable.noctalia-shell # for wayland
      unstable.nodejs # for emacs to install lsp packages
      unstable.nova # find outdated, deprecated helm charts on your cluster
      unstable.nsxiv # image viewer
      unstable.nsz # .nsz to .nsp nintendo switch game convertor for ryujinx emulator
      unstable.ntfs3g # make udiskie mount NTFS partitions without problems
      unstable.offlineimap
      unstable.openshift # kubernetes for stake holders
      unstable.opensnitch-ui # enable interactive notifications for application firewall
      unstable.openssl
      unstable.ops # build nanos unikernels (for java apps)
      unstable.optipng # optimize png
      unstable.p7zip # 7z great archiving tool
      unstable.pandoc # emacs's markdown compiler and org-mode dep
      unstable.pavucontrol # pipewire buffer size and latency settings can be done from there
      unstable.pcmanfm # lightweight file manager
      unstable.peek # record desktop gifs
      unstable.picom # xorg compositor with animation support
      unstable.pinentry-gnome3
      unstable.pipenv
      unstable.pkg-config # needed for building ruby files
      unstable.plantuml-c4 # org-mode graph generation
      unstable.pluto # like kubent
      unstable.pnpm # better npm?
      unstable.poppler-utils # doom emacs dirvish dep for viewing pdfs first page
      unstable.postgresql
      unstable.posting # tui api client
      unstable.power-profiles-daemon
      unstable.prettier # prettier code formatter for js/ts
      unstable.profanity # tui xmpp
      unstable.prometheus
      unstable.proteus # NAM (disabled due to compilation errors)
      unstable.proton-vpn # vpn
      unstable.protonup-ng # great wine fork
      unstable.psmisc # optional dependency for fzf-tmux
      unstable.pulseaudio # installed for pactl to work. was trying to record screen with ffmpeg and pipewire. needed pactl
      unstable.pulseaudioFull
      unstable.python313
      unstable.python313Packages.diagrams
      unstable.python313Packages.isort
      unstable.python313Packages.nose2
      unstable.python313Packages.pytest
      unstable.pywal16 # generate colorschemes
      unstable.qalculate-gtk # dependency for rofi-calc
      unstable.qemu # virtualization for good + all supported architectures like arm, mips, powerpc etc.
      unstable.qjackctl # reduce latency
      unstable.qjoypad # play ryujinx games with mouse and keyboard
      unstable.qpwgraph
      unstable.quickemu # installed for installing macos sonoma (for react-native dev)
      unstable.quickgui # gui for quickemu
      unstable.quickshell # noctalia is based on this one. dependency
      unstable.qutebrowser # keyboard centric web browser
      unstable.radare2
      unstable.rakkess # check what access do you have on a kubernetes cluster
      unstable.ranger # tui file manager
      unstable.react-native-debugger # official react-native debugger
      unstable.reader # render curl output better
      unstable.reaper
      unstable.regex-tui # try regex interactively
      unstable.ripgrep # doom emacs dep
      unstable.rmpc # mpd client better than ncmpcpp
      unstable.rocmPackages.clang # for clang-format. doom emacs java and cc module dep
      unstable.rofi # application launcher
      unstable.rofi-calc # do calculations in rofi
      unstable.ruby # language
      unstable.rust-analyzer # doom emacs dependency
      unstable.rustc
      unstable.rustywind # for tailwind lsp
      unstable.ryubing # switch emulator (ryujinx replacement)
      unstable.salt
      unstable.sc-controller # emulate joysticks on linux (to play swtich games using mouse and keyboard)
      unstable.scarlett2 # update firmware of focusrite scarlett devices
      unstable.scrcpy # control your android from your pc
      unstable.screenkey # show key presses on screen (screencast)
      unstable.scrot # for emacs's org-mode screen shot capability
      unstable.sdkmanager # manage android sdk versions
      unstable.serpl # find and replace
      unstable.sesh # session manager for tmux
      unstable.shellcheck
      unstable.shfmt # doom emacs's dep for bash file formatter to work
      unstable.skim # skim instead of fzf
      unstable.slack-term # tui slack
      unstable.slurp # region select. combine it with grim to select region for screenshot
      unstable.smartmontools # check health of ssd drives
      unstable.soapui # xml based apis
      unstable.socat # serial communication with quickemy headless hosts witout ssh
      unstable.spice-vdagent # shared clipboard between qemu guests and host
      unstable.sqlite
      unstable.ssh-askpass-fullscreen
      unstable.starship # cross shell (very cool)
      unstable.stdenv # build-essentials
      unstable.stow # manage dotfiles
      unstable.stress # simulate high cpu load for testing
      unstable.stylelint # doom emacs web module dep
      unstable.sunshine # better rdp
      unstable.supercollider_scel # supercollider with emacs extension scel
      unstable.swaybg # set wallpapers in wayland
      unstable.swayidle # for wayland auto lock screen
      unstable.sxhkd # simple x11 hotkey daemon
      unstable.syncthing # I install the package instead of service because it gives permission issues. I start it from .xprofile
      unstable.sysstat # get system statistics (used for tmux status bar cpu usage)
      unstable.tabbed # make any tool tabbed
      unstable.tenacity # audaicty fork
      unstable.terminal-parrot # wow
      unstable.termscp # use SCP/SFTP/FTP/S3/SMB from tui
      unstable.terraform # iac
      unstable.terraform-local # use terraform with localstack
      unstable.terraform-ls # lsp for emacs terraform mode
      unstable.terraformer # reverse terraform!
      unstable.texliveFull # full latex environment for pdf exports (doom emacs)
      unstable.texlivePackages.booktabs # Publication quality tables in LaTeX
      unstable.texlivePackages.fontspec # Advanced font selection in XeLaTeX and LuaLaTeX
      unstable.texlivePackages.fvextra # Extensions and patches for fancyvrb (for syntax highlighting)
      unstable.texlivePackages.librebaskerville # main font
      unstable.texlivePackages.microtype # Subliminal refinements towards typographical perfection
      unstable.texlivePackages.minted # syntax highlighting
      unstable.texlivePackages.plex # sans and mono fonts
      unstable.texlivePackages.titlesec # Select alternative section titles
      unstable.texlivePackages.xcolor # Driver-independent color extensions for LaTeX and pdfLaTeX
      unstable.tftui # interractive terraform state browser
      unstable.tiddlywiki
      unstable.timidity # play midi files usin mpd
      unstable.tldr # too long didn't read the manual
      unstable.tlock # 2FA tui
      unstable.tmux # life saver
      unstable.tmux-xpanes # run multiple commands on multiple tmux panes at once
      unstable.tmuxp # declarative tmux sessions (disabled due to compilation errors..)
      unstable.tofu-ls # opentofu lsp server (for emacs eglot)
      unstable.tonelib-gfx # good guitar amp
      unstable.tonelib-jam # 3d tab editor (paid)
      unstable.tonelib-metal # all in one guitar rig
      unstable.toolong # inspect logs like a pro
      unstable.tor-browser # just in case
      unstable.translate-shell # needed for using rofi as translate engine
      unstable.transmission_4-gtk # torrents and stuff
      unstable.tree # file trees
      unstable.tree-sitter # parser for programming
      unstable.tshark # scan local network
      unstable.tts # coqui-ai TTS (works with cpu)
      unstable.turbovnc
      unstable.tuxguitar # guitar pro for linux
      unstable.ty # python lsp written in rust (bettern than pyright, recommended by doom emacs)
      unstable.udiskie # auto mount hotplugged block devices
      unstable.unclutter-xfixes # hide mouse cursor after a time period
      unstable.undollar # you copy and paste code from internet? you simply need it
      unstable.unimatrix
      unstable.unp # archive agnostic uncompressor
      unstable.unrar # non-free but needed
      unstable.unzip # mendatory
      unstable.uv # vital python package. solves all those python version and dependency problems
      unstable.vim # fallback text editor
      unstable.vips # doom emacs dirvish dep for displaying images in buffer
      unstable.virglrenderer # allows a qemu guest to use the host GPU for accelerated 3D rendering
      unstable.virt-viewer # display spice vms from proxmox
      unstable.virtiofsd # share file system between host and guests
      unstable.vlc # play dvds .VOB
      unstable.vscodium # just in case ide
      unstable.vulkan-tools # gpu info viewer (lutris needs it)
      unstable.w3m # image display for terminal
      unstable.walker # better application launcher for wayland with bunch of features
      unstable.waybar # status bar for wayland
      unstable.weechat # overlayed my custom weechat with plugins
      unstable.wget # download things
      unstable.wineWow64Packages.staging # bleeding edge wine
      unstable.wineasio # for playing Rocksmith 2014 Remastered
      unstable.winetricks # install dlls for windows games/apps
      unstable.wipe # securely wipe directories and files on hdd/ssd
      unstable.wireshark # network analizer
      unstable.wkhtmltopdf # convert webpages to pdf (for emacs note taking using pdf-tools and org-noter)
      unstable.wl-clipboard # wayland clipboard
      unstable.wlsunset # wayland screen temperature (noctalica-shell dependency)
      unstable.woff2 # convert .tcc files to .woff
      unstable.wtfutil # build customized tui dashboards
      unstable.x42-gmsynth
      unstable.x42-plugins # collection of lv2 plugins by Robin Gareus
      unstable.xbacklight # set brightness on laptop
      unstable.xcalib # invert colors of x
      unstable.xclip # clipboard for xorg
      unstable.xcolor # color picker for xorg
      unstable.xd # i2p torrenting
      unstable.xdg-desktop-portal-gtk # for xdg portal
      unstable.xdotool # simulate keyboard and mouse events
      unstable.xev # find keysims
      unstable.xinit # for startx command to work
      unstable.xournalpp # draw shapes using your wacom tablet
      unstable.xpra # remove desktop on steroids?
      unstable.xsct # protect your eyes (blue light filter) (disabled because using redshift)
      unstable.xsel # clipboard for xorg
      unstable.xwayland-satellite # for niri
      unstable.xwinwrap # gif wallpapers on xorg
      unstable.yabridge # use windows vsts on linux wine is requirement here
      unstable.yabridgectl # yabridge control utility
      unstable.yarn
      unstable.yazi # new ranger
      unstable.ydotool # xdotool for wayland
      unstable.youtube-tui
      unstable.yq # jq on steroids
      unstable.yt-dlp # youtube video downloader + you can watch videos from mpv using this utility
      unstable.zathura # pdf reader
      unstable.zbar # scan qr codes etc.
      unstable.zellij # better tmux (or is it?)
      unstable.zip # archiving utility
      unstable.zsh
      unstable.zsh-abbr # abbreviations just like fish
      unstable.zsh-autosuggestions
      unstable.zsh-fast-syntax-highlighting
      unstable.zstd # extract .zst files
      unstable.fishPlugins.done # get notified when jobs finish

      (unstable.pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-import
      ]))


      # nixos 25.11 packages
      stable.glances
      stable.libreoffice-qt6 # open .docx
      stable.vagrant # declarative virtual machines (too much compilation!)
      stable.lutris # install and launch windows and linux games

      (stable.retroarch.withCores (cores: with cores; [
        mesen              # nes
        snes9x             # snes
        beetle-psx-hw      # ps1
        pcsx2              # ps2
        fbneo              # arcade (MAME)
        mgba               # gba
        genesis-plus-gx    # sega genesis/megadrive
        sameboy            # gb + gbc
        mupen64plus        # n64
        melonds            # nds
      ]))

      # failing nix packages
      # stable.unigine-valley # test GPU drivers (cannot build)
      # stable.retroshare # p2p file sharing (failing to build)
    ];
  };

  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true; # use gpg key as your ssh key
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    tmux = {
      enable = true;
    };

    ssh = {
      enableAskPassword = true;
    };

    xwayland = {
      enable = true;
    };

    niri = {
      enable = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-ld = {
      enable = true;
      libraries = with stable; [
        libx11 # for suckless slstatus, dwm etc. to run
        libxinerama # dwm needs it
        libxshmfence # for mechvibes to run

        # to fix lutris game launches
        stdenv.cc.cc.lib
        glibc
        libGL
        vulkan-loader
        libgcc
      ];
    };

    # manage environments depending on current directory (doom emacs dep)
    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    # run programs without internet access
    firejail = {
      enable = true;
    };

    # wayland dwm like window manager
    river-classic = {
      enable = true;
    };

    # suckless screen locker
    slock = {
      enable = true;
      package = slockFlexipatch;
    };

    # pretty shell
    starship = {
      enable = true;
    };

    # wayland window manager
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };

    fish = {
      enable = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true; # fixes window manager specific problems

    };
    gamemode.enable = true; # temporarily apply optimizations to os and gaming process

    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [
          pkgs.lz4
          # add other libs AppImage needs here
        ];
      };
    };
  };

  # List services that you want to enable:
  services = {

    # silence the agetty "Welcome to NixOS" banner on tty
    getty = {
      greetingLine = "";
      helpLine = "";   # removes the "run nixos-help" line
    };

    # SSD/NVME healthcare
    fstrim = {
      enable = true;
      interval = "weekly";
    };

    logind = {
      settings = {
        Login = {
          HandlePowerKey = "hibernate";
          HandlePowerKeyLongPress = "poweroff";
          HandleLidSwitch = "hibernate";
          HandleLidSwitchExternalPower = "suspend";
        };
      };
    };

    dnscrypt-proxy = {
      enable = true;
      # Settings reference:
      # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
        # Add this to test if dnscrypt-proxy is actually used to resolve DNS requests
        query_log.file = "/var/log/dnscrypt-proxy/query.log";
        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };

        # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        # server_names = [ ... ];
      };
    };

    pipewire = {
      # sound (pipewire)
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # fix retroarch playstation audio cracklings
      extraConfig.pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 512;
          default.clock.min-quantum = 512;
          default.clock.max-quantum = 512;
        };
      };
    };

    openssh.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];

      displayManager = {
        lightdm = {
          enable = true;
          greeters = {
            slick.enable = true;
          };
        };
      };
      windowManager = {
        dwm = {
          enable = true;
          package = dwmFlexipatch;
        };
      };
    };

    power-profiles-daemon.enable = true; # set power profiles
    upower.enable = true; # poweroff etd. (I guess)

    udisks2 = {
      # mount disks without sudo (requires udiskie)
      enable = true;
    };

    gvfs = {
      # enable android file system mount in pcmanfm
      enable = true;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;  # needed for 32-bit wine games (lutris fix)
    };
    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bl
    };
  };

  security = {
    protectKernelImage = false; # sometimes required if lockdown mode interferes (for hibernation)
    rtkit.enable = true;
  };

  nix = {
    # lower build process priority — makes the builder yield to other processes:
    daemonCPUSchedPolicy = "idle"; # only use CPU when nothing else needs it
    daemonIOSchedClass = "idle"; # same for disk I/O

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };

    # enable flakes
    settings = {
      # prevent compiling from source if possible
      builders-use-substitutes = true;
      always-allow-substitutes = true;
      substituters = [ "https://cache.nixos.org/" ];
      trusted-substituters = [ "https://cache.nixos.org/" ];

      auto-optimise-store = true; # save space by hardlinking stuff in /nix/store
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # limit parallel jobs — by default Nix uses all cores, which can make the system unresponsive:
      max-jobs = 2; # number of parallel builds
      cores = 2; # cores per build job
    };
  };

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # allow ssh
        22000 # allow syncthing
      ];
      allowedUDPPorts = [
        22000 # allow syncthing QUIC protocol
        21027 # allow syncthing local discovery IPv4/IPv6
      ];
    };
  };

  # increase performance for gaming and emulation
  powerManagement.cpuFreqGovernor = "performance";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "25.11"; # Did you read the comment?
    activationScripts.post-rebuild = ''
      # echo "running post-build commands"
      # runuser -u savolla -- protonup -y
      # runuser -u savolla -c 'protonup'

      # echo "stowing dotfiles..."

      # cd /home/savolla/project/repos/one-ring/dotfiles/$HOSTNAME || exit 1
      # ${pkgs.stow}/bin/stow --target=$HOME . --restow

      # echo "stowing tools..."
      # cd /home/savolla/project/repos/one-ring/dotfiles/../tools || exit 1
      # ${pkgs.stow}/bin/stow --target=$HOME/project . --restow
    '';
  };
}
