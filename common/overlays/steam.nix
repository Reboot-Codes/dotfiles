final: prev: {
  steam = prev.steam.override {
    # withJava = true;
    # withPrimus = true;
    extraPkgs = steam_pkgs: with steam_pkgs; [
      bumblebee
      mesa-demos
    ];
  };
}
