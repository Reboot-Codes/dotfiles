{ pkgs, pkgs-unstable, ... }: {
  unstable = with pkgs; [
    # Horny
    intiface-central
    cargo-mommy
    cargo-vibe # TODO: Customize invocation properly.
  ];

  packages = unstable;
}