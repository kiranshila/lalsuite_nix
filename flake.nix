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
            nativeBuildInputs = with pkgs; [pkg-config];
            buildInputs = with pkgs; [
              zlib
              gsl
              fftw
              fftwFloat
              hdf5_1_10
            ];
            configurePhase = ''
              ./configure --disable-swig --prefix=$out CFLAGS="-Wno-macro-redefined -flto" LDFLAGS="-flto"
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
            nativeBuildInputs = with pkgs; [pkg-config];
            buildInputs = with pkgs; [
              zlib
              gsl
              fftw
              fftwFloat
              hdf5_1_10
              lalDeriv
            ];
            configurePhase = ''
              ./configure --disable-swig --prefix=$out CFLAGS="-Wno-macro-redefined -flto" LDFLAGS="-flto"
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

#autoreconfHook