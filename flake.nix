{
  inputs.nixpkgs.url = "github:kiranshila/nixpkgs/master";
  outputs = {
    self,
    nixpkgs,
  }: {
    defaultPackage.x86_64-linux = with import nixpkgs {system = "x86_64-linux";};
      clangStdenv.mkDerivation {
        name = "lalsuite";

        src = fetchurl {
          url = "https://software.igwn.org/lscsoft/source/lalsuite/lal-7.5.0.tar.xz";
          hash = "sha256-m7aSATxTSIDPPut8jkXCoyvW10588MaRj2OLwVvQz10=";
        };

        nativeBuildInputs = with pkgs; [autoconf automake pkg-config git];

        buildInputs = with pkgs; [
          zlib
          gsl
          fftw
          fftwFloat
          (pkgs.python3.withPackages (pp: [
            pp.numpy
          ]))
        ];

        configurePhase = ''
          ./configure --disable-swig --prefix=$out CFLAGS="-Wno-macro-redefined -flto" LDFLAGS="-flto"
        '';
      };
  };
}
