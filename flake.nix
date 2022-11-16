{
  description = "Wolf's CV";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.gitignore = {
    url = "github:hercules-ci/gitignore.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    gitignore,
  }:
    with flake-utils.lib;
      eachDefaultSystem (system: let
        inherit (gitignore.lib) gitignoreSource;
        pkgs = nixpkgs.legacyPackages.${system};

        tcsl1000 = pkgs.stdenvNoCC.mkDerivation {
          pname = "tcsl1000";
          version = "1997-01-19";
          srcs = [
            (builtins.fetchurl {
              url = "https://mirrors.ctan.org/fonts/ec/ready-mf/tcsl1000.mf";
              sha256 = "sha256:09i822lyzlvp2lzwdwwi23xvzv4rcm9shaacbrhx5xbjvznr6kfa";
            })
            (builtins.fetchurl {
              url = "https://mirrors.ctan.org/fonts/ec/tfm/tcsl1000.tfm";
              sha256 = "sha256:005v86m9jd61rfs6b612w63jhdxzv0gpblxjfj3y46662f5zjs6n";
            })
          ];

          phases = ["unpackPhase" "installPhase"];

          sourceRoot = "./";

          unpackCmd = ''
            name=$(basename $(stripHash $curSrc))
            cp $curSrc ./$name
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/share/fonts/tfm $out/share/fonts/ready-mf
            cp *.tfm $out/share/fonts/tfm/
            cp *.mf $out/share/fonts/ready-mf/

            runHook postInstall
          '';
        };

        tex = pkgs.texlive.combine {
          inherit
            (pkgs.texlive)
            scheme-minimal
            latex-bin
            latexmk
            metafont

            # Packages
            moderncv
            colortbl
            fontawesome5
            pgf
            multirow
            arydshln
            geometry
            infwarerr
            kvoptions
            epstopdf-pkg
            ;
        };
      in {
        packages.default = pkgs.stdenvNoCC.mkDerivation rec {
          name = "resume";
          src = gitignoreSource ./.;

          buildInputs = [pkgs.coreutils tex tcsl1000 pkgs.gawk];
          phases = ["unpackPhase" "buildPhase" "installPhase"];

          buildPhase = ''
            runHook preBuild

            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            ln -s ${tcsl1000}/share/fonts .cache/texmf-var/
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -interaction=nonstopmode -pdf \
              resume.tex

            runHook postBuild
          '';

          installPhase = ''
            mkdir -p $out
            cp resume.pdf $out
          '';
        };
      });
}
