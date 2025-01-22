{ pkgs, pkgs-stable, groups }: {
  unstable = with pkgs; lib.lists.flatten (
    builtins.map (group: let group = import (../. + "/packages/${group}.nix"); in (if builtins.hasAttr "unstable" then group.unstable)) groups
  );

  stable = with pkgs; lib.lists.flatten (
    builtins.map (group: let group = import (../. + "/packages/${group}.nix"); in (if builtins.hasAttr "stable" then group.stable)) groups
  );
}