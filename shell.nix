with import <nixpkgs> {}
stdenv.mkDerivation rec {
  name = "RoseQuartz Environment";
  
  buildInputs = with pkgs; [ wlroots libudev libevdev pixman libGL xorg.libX11 libxkbcommon ];
  nativeBuildInputs = with pkgs; [ zig wayland wayland-protocols pkgconfig ];
}