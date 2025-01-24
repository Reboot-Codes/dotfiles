final: prev: {
  waydroid = prev.waydroid.overrideAttrs {
    version = "1.4.2-update-regex-for-deprecation-warning";

    src = pkgs.fetchFromGitHub {
      owner = prev.waydroid.pname;
      repo = prev.waydroid.pname;
      rev = "66c8343c4d2ea118601ba5d8ce52fa622cbcd665";
      hash = "sha256-ywlykYPLMx3cI6/7JOL0UDIcymzf0qug5A/c9JaCr+k";
    };
  };
}