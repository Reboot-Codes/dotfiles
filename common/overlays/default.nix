let
  discord = import ./discord.nix;
  spotify = import ./spotify.nix;
  looking-glass = import ./looking-glass;
in [
  discord
  spotify
  # looking-glass
]