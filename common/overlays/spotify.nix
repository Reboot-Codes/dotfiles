final: prev: {
  spotify = prev.spotify // {
    installPhase = builtins.replaceStrings [
      "runHook postInstall"
      ''
        bash <(curl -sSL https://spotx-official.github.io/run.sh) -P "$out/share/spotify"
        runHook postInstall
      ''
    ]
    prev.spotify.installPhase;
  };
}