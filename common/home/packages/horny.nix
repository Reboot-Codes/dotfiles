{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Horny
    intiface-central
    cargo-mommy
    cargo-vibe # TODO: Customize invocation properly.
  ];
in {
  packages = unstable;
}