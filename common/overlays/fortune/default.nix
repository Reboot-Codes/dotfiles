final: prev: {
  fortune = prev.fortune // {
    postFixup = final.lib.concatLines ( (if prev.fortune ? postFixup then prev.fortune.postFixup else "") (''
      echo "Writing custom fortunes..."
      cp ${ ./custom-fortunes.nix } > $out/share/games/fortunes/reboots-fortunes
      echo "Custom fortunes:"
      cat $out/share/games/fortunes/reboots-fortunes

      echo "Running strfile..."
      $out/bin/strfile $out/share/games/fortunes/reboots-fortunes $out/share/games/fortunes/reboots-fortunes.dat
      echo "Done! Added custom fortunes. :3"
    ''));
  };
}