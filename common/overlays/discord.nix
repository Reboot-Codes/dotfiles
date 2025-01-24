final: prev: {
  discord = prev.discord.override {
    # withOpenASAR = true; # This is kinda, really buggy...
    withVencord = true;
  };
}
