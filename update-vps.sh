nixos-rebuild switch \
  --flake .#vps-valkyrie-edge-nixos \
  --target-host root@vps-valkyrie-edge-nixos \
  --elevate=sudo
