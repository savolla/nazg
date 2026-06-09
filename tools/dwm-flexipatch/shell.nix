{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  name = "dwm-build-shell";

  buildInputs = [
    pkgs.gcc # C compiler
    pkgs.gnumake # Make tool
    pkgs.libX11 # X11 library
    pkgs.libXinerama # Optional: for multi-monitor support
    pkgs.libXft # Optional: font rendering
    pkgs.pkg-config # For compile-time library detection
  ];

  # Environment variables to make building easier
  shellHook = ''
    echo "Welcome to the DWM build shell!"
    echo "Use 'make clean install' inside the dwm source directory."
  '';
}
