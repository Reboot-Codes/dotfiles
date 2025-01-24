let
  discord = import ./discord.nix;
  spotify = import ./spotify.nix;
in [
  discord
  spotify
]