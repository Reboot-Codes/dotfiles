{ pkgs, pkgs-unstable, ... }: {
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

  packages = unstable ++ stable;
}