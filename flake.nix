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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        # Build LALSuite
        lalsuiteDeriv = with pkgs;
          clangStdenv.mkDerivation rec {
            pname = "lalsuite";
            version = "7.5.0";
            src = fetchurl {
              url = "https://software.igwn.org/lscsoft/source/lalsuite/lal-${version}.tar.xz";
              hash = "sha256-m7aSATxTSIDPPut8jkXCoyvW10588MaRj2OLwVvQz10=";
            };
            nativeBuildInputs = with pkgs; [autoconf automake pkg-config git];
            buildInputs = with pkgs; [
              zlib
              gsl
              fftw
              fftwFloat
            ];
            configurePhase = ''
              ./configure --disable-swig --prefix=$out CFLAGS="-Wno-macro-redefined -flto" LDFLAGS="-flto"
            '';
          };
      in {
        packages = {
          default = lalsuiteDeriv;
          lalsuite = lalsuiteDeriv;
        };
      });
}
