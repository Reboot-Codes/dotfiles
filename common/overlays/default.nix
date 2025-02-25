let
  discord = import ./discord.nix;
  spotify = import ./spotify.nix;
  looking-glass = import ./looking-glass;
  fortune = import ./fortune;
in [
  discord
  spotify
  # looking-glass
  fortune
]