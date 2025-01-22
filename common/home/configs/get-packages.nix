{ pkgs, pkgs-stable, groups }: pkgs.lib.lists.flatten (
  builtins.map (groupName:
    let
      group = import (../packages + "/${groupName}.nix") { inherit pkgs pkgs-stable; };
    in (
      if (builtins.hasAttr "packages" group) then
        group.packages
      else
        []
    )
  ) groups
)