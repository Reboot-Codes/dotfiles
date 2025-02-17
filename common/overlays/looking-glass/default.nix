# TODO: WARNING: This is temporary while https://github.com/NixOS/nixpkgs/issues/379503 is being fixed upstream by looking glass contributors...
final: prev: {
  # linuxPackages_latest = prev.linuxPackages_latest.extend (lfinal: lprev: {
  #   kvmfr = prev.linuxPackages_latest.kvmfr.overrideAttrs (old: {
  #     patches = [
  #       (prev.fetchpatch {
  #         url = "https://github.com/gnif/LookingGlass/commit/4251a5c5fe7723c5dc068839debd76a5148953b2.diff";
  #         sha256 = "sha256-CswVgctC4G58cNFHrAh3sHsgOlB2ENJ/snyWQAHO6Ks=";
  #         stripLen = 1;
  #         includes = [
  #           "dkms.conf"
  #           "kvmfr.c"
  #         ];
  #       })
  #     ];
  #   });
  # });

  looking-glass-client = prev.looking-glass-client.overrideAttrs (old: {
    version = "master";
    src = prev.fetchFromGitHub {
      owner = "ticpu";
      repo = "LookingGlass";
      rev = "4251a5c5fe7723c5dc068839debd76a5148953b2";
      sha256 = "sha256-R2Ic1FDMT7VkfwNJk5IAAPXtuDfWqqUOr5jwo8C02S0=";
      fetchSubmodules = true;
    };
    # patches = [ ./nanosvg-unvendor.diff ];
  });
}