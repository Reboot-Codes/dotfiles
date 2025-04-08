{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Crypto (see stable)
    monero-gui
    monero-cli
    xmrig-mo
		xmrig-proxy
		bisq2
  ];

  stable = with pkgs-stable; [
    # Crypto
    electrum
    electrum-ltc
  ];
in {
  packages = unstable ++ stable;
}
