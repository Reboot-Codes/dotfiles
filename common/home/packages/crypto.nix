{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Crypto (see stable)
    monero-gui
    monero-cli
    xmrig
  ];

  stable = with pkgs-stable; [
    # Crypto
    electrum
    electrum-ltc
  ];
in {
  packages = unstable ++ stable;
}