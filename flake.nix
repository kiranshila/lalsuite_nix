{
  description = "LALSuite in a nix flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs:
    with inputs;
      flake-utils.lib.eachDefaultSystem (system: let
        # Setup nixpkgs
        pkgs = import nixpkgs {inherit system;};

        lalDeriv = with pkgs;
          clangStdenv.mkDerivation rec {
            pname = "lal";
            version = "7.5.0";
            src = fetchurl {
              url = "https://software.igwn.org/lscsoft/source/lalsuite/lal-${version}.tar.xz";
              hash = "sha256-m7aSATxTSIDPPut8jkXCoyvW10588MaRj2OLwVvQz10=";
            };
            nativeBuildInputs = with pkgs; [autoreconfHook pkg-config lld];
            buildInputs = with pkgs; [
              zlib
              gsl
              fftw
              fftwFloat
              hdf5
            ];
            configurePhase = ''
              ./configure --disable-swig --prefix=$out CFLAGS="-Wno-macro-redefined -flto -fuse-ld=lld" LDFLAGS="-flto -fuse-ld=lld"
            '';
          };

        lalsimulationDeriv = with pkgs;
          clangStdenv.mkDerivation rec {
            pname = "lalsimulation";
            version = "5.4.0";
            src = fetchurl {
              url = "https://software.igwn.org/lscsoft/source/lalsuite/lalsimulation-${version}.tar.xz";
              hash = "sha256-tsF4HoETQQiEXzjjpmljrmYcKpFdQTzxTmiZWIjcwKU=";
            };
            nativeBuildInputs = with pkgs; [autoreconfHook pkg-config lld];
            buildInputs = with pkgs; [
              lalDeriv
            ];
            configurePhase = ''
              ./configure --disable-swig --prefix=$out CFLAGS="-Wno-macro-redefined -flto -fuse-ld=lld" LDFLAGS="-flto -fuse-ld=lld"
            '';
          };

      in {
        packages = {
          default = lalsimulationDeriv;
          lal = lalDeriv;
          lalsimulation = lalsimulationDeriv;
        };
      });
}
