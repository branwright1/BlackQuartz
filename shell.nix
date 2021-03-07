with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "BlackQuartz-env";
  buildInputs = with pkgs; [
    libGL
    pixman
    libudev
    wlroots
    wayland
    libevdev
    xorg.libX11
    libxkbcommon
    wayland-protocols
  ];
  nativeBuildInputs = with pkgs; [ ninja meson ];
}
