{
  description = "A Nix-flake-based React Native development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:

    utils.lib.eachDefaultSystem (system:
      let
        # react-native dependencies versions
        nodejsVersion = 18;

        overlays = [
          (final: prev: rec {
            nodejs = prev."nodejs-${toString nodejsVersion}_x";
            yarn = prev.yarn.override { inherit nodejs; };
            ruby = prev.ruby_3_2;
          })
        ];

        pkgs = import nixpkgs { inherit overlays system; };

      in
      rec {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # nodejs 18 (specified by overlay)
            nodejs

            # yarn with nodejs 18 (specified by overlay)
            yarn

            # ruby with cocoapods (specified by overlay)
            ruby

            # react-native development dependencies 
            watchman

            bundix

            jekyll
          ];

          shellHook = ''
            alias start="bundle exec jekyll serve"
          '';
          
        };

      packages = rec {
        gelos-site = pkgs.callPackage ./default.nix {};
        gelos-site-serve = pkgs.writeShellScriptBin "serve" ''
          echo "Serving on http://localhost:8000"
          ${pkgs.webfs}/bin/webfsd -F -f index.html -r ${gelos-site}/public
        '';
        remove-nbsp = pkgs.writeShellScriptBin "remove-nbsp" ''
          ${pkgs.gnused}/bin/sed 's/\xC2\xA0/ /g' -i $(find . -name '*.md')
        '';
        default = gelos-site;
      };

      apps = rec {
        gelos-site-serve = {
          type = "app";
          program = "${packages.gelos-site-serve}/bin/serve";
        };
        default = gelos-site-serve;
      };

      });
}
