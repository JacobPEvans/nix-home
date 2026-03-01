# Nix quality checks - single source of truth for pre-commit and CI
# Used by flake.nix checks output, ensuring DRY principle
{
  pkgs,
  nixpkgs,
  src,
  home-manager,
  homeModule,
}:
{
  # Check Nix formatting with nixfmt-rfc-style
  # Uses treefmt configured with nixfmt formatter
  # Copy source to writable $TMPDIR since treefmt needs to write temp files
  formatting =
    pkgs.runCommand "check-formatting"
      {
        nativeBuildInputs = [ pkgs.nixfmt-rfc-style ];
      }
      ''
        cp -r ${src} $TMPDIR/src
        chmod -R u+w $TMPDIR/src
        cd $TMPDIR/src
        ${pkgs.lib.getExe pkgs.treefmt} --fail-on-change --no-cache --formatters nixfmt .
        touch $out
      '';

  # Lint Nix files for anti-patterns and code smells
  # Catches common mistakes and suggests improvements
  statix = pkgs.runCommand "check-statix" { } ''
    cd ${src}
    ${pkgs.lib.getExe pkgs.statix} check .
    touch $out
  '';

  # Check for unused Nix code (dead bindings)
  # -L: ignore lambda pattern names (config, lib, pkgs are common in modules)
  # --fail: exit with error if unused bindings found
  deadnix = pkgs.runCommand "check-deadnix" { } ''
    cd ${src}
    ${pkgs.lib.getExe pkgs.deadnix} -L --fail .
    touch $out
  '';

  # Lint shell scripts with shellcheck
  # Catches common bugs: unquoted variables, undefined vars, useless use of cat, etc.
  # Excludes .git directories and nix store paths
  # --severity=warning: Only fail on warning/error level (not info style suggestions)
  # SC1091: Exclude "not following" errors for external sources (can't resolve in Nix sandbox)
  # Excludes zsh scripts (shellcheck only supports sh/bash/dash/ksh)
  # Uses find with -print0 and xargs -0 for robustness with filenames containing spaces and special characters
  # TODO: Fix info-level issues (SC2086 quoting) in shell scripts for stricter checking
  shellcheck = pkgs.runCommand "check-shellcheck" { } ''
    cd ${src}
    find . -name "*.sh" -not -path "./.git/*" -not -path "./result/*" -print0 | \
    xargs -0 bash -c '
      for script in "$@"; do
        # Skip zsh scripts (shellcheck does not support them)
        if head -1 "$script" | grep -q "zsh"; then
          echo "Skipping zsh script: $script"
        else
          echo "Checking $script..."
          ${pkgs.lib.getExe pkgs.shellcheck} --severity=warning --exclude=SC1091 "$script"
        fi
      done
    ' bash
    touch $out
  '';

  # Smoke-test dev shell flakes: verify each shell's devShell evaluates
  # Catches: broken packages, missing inputs, syntax errors in shell flakes
  # Only checks flake-based shells (those with flake.nix); skips shell.nix-based ones
  # Eval-only: uses builtins.unsafeDiscardStringContext to avoid building shell dependencies
  dev-shell-eval =
    let
      shellsDir = src + "/shells";
      shellEntries = builtins.readDir shellsDir;
      # Filter to directories that contain a flake.nix
      flakeShells = builtins.filter (
        name: shellEntries.${name} == "directory" && builtins.pathExists (shellsDir + "/${name}/flake.nix")
      ) (builtins.attrNames shellEntries);
      # Import each shell's flake and evaluate its devShell drvPath
      # Pass nix-config = src for shells that reference the repo root (e.g. image-building)
      evalShell =
        name:
        let
          shellFlake = import (shellsDir + "/${name}/flake.nix");
          outputs = shellFlake.outputs {
            inherit nixpkgs;
            nix-config = src;
          };
          # Force evaluation of drvPath but discard string context so we don't
          # create a build-time dependency on the shell's closure
          drvPath = builtins.unsafeDiscardStringContext outputs.devShells.${pkgs.system}.default.drvPath;
        in
        "${name}: ${drvPath}";
      results = builtins.map evalShell flakeShells;
    in
    pkgs.runCommand "check-dev-shell-eval" { } ''
      echo "Dev shell smoke tests passed (${toString (builtins.length flakeShells)} shells):"
      ${builtins.concatStringsSep "\n" (builtins.map (line: "echo '  ${line}'") results)}
      touch $out
    '';

  # Verify the home-manager module evaluates without errors
  # Catches: broken imports, missing args, type errors, assertion failures
  module-eval =
    let
      # Use a pkgs instance with allowUnfree for the module eval check since
      # the module enables vscode (unfree). This is test-only; real deployments
      # set allowUnfree in their nixpkgs config.
      pkgsWithUnfree = import nixpkgs {
        inherit (pkgs) system;
        config.allowUnfree = true;
      };
      hmConfig = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsWithUnfree;
        extraSpecialArgs = {
          userConfig = {
            nix.homeManagerStateVersion = "24.11";
            user = {
              name = "test-user";
              email = "test@example.com";
              fullName = "Test User";
            };
            git = {
              editor = "vim";
              defaultBranch = "main";
            };
            gpg.signingKey = "";
          };
        };
        modules = [
          homeModule
          {
            home = {
              username = "test-user";
              homeDirectory = "/home/test-user";
              stateVersion = "24.11";
            };
          }
        ];
      };
    in
    hmConfig.activationPackage;
}
