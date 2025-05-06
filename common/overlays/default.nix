let
  discord = import ./discord.nix;
  spotify = import ./spotify.nix;
  fortune = import ./fortune;
  steam = import ./steam.nix;
	kdenlive = import ./kdenlive.nix;
in [
  discord
  spotify
  fortune
  # steam
	# kdenlive
]
