let
  discord = import ./discord.nix;
  spotify = import ./spotify.nix;
  fortune = import ./fortune;
  steam = import ./steam.nix;
in [
  discord
  spotify
  fortune
  # steam
]
