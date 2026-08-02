{ pkgs, pkgs-stable, ... }:
let
  unstable = with pkgs; [
    # Media Acquisition
    ani-cli
    losslessaudiochecker
    transmission_4-qt
    qbittorrent
    unshield
    spotify
    ytmdl
    ipget
    torsocks
    lbry
    guymager
    vcdimager
    gImageReader
    yt-dlp
  ];
in
{
  packages = unstable;
}
