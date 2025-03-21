{ pkgs, pkgs-stable, ... }: let
  unstable = with pkgs; [
    # Office (see stable)
    keepassxc
    libreoffice-qt
    hunspell
    hunspellDicts.en-us
    hunspellDicts.de-de
    hunspellDicts.es-mx
    kdePackages.kcalc
    zotero
    obsidian
    emacs-gtk
    organicmaps
    pdfslicer
    asciidoc-full-with-plugins
    diamond
    kdePackages.kclock
    kdePackages.kleopatra
    kdePackages.filelight
    gnome-decoder
    junction
    sigil
    openboard
    kdePackages.marble
    kdePackages.itinerary
    scribus
    upscayl
    collision
    paperwork
    simple-scan
    kana
    warp
    authenticator
    gnome-obfuscate
    curtail
    xournalpp

    # Translation
    # whisper-ctranslate2
    libretranslate
    morsel
    translatelocally
    translatelocally-models.uk-en-tiny
    translatelocally-models.tr-en-tiny
    translatelocally-models.sq-en-tiny
    translatelocally-models.sl-en-tiny
    translatelocally-models.pl-en-tiny
    translatelocally-models.nn-en-tiny
    translatelocally-models.nb-en-tiny
    translatelocally-models.mt-en-tiny
    translatelocally-models.mk-en-tiny
    translatelocally-models.is-en-tiny
    translatelocally-models.is-en-base
    translatelocally-models.fr-en-tiny
    translatelocally-models.et-en-tiny
    translatelocally-models.es-en-tiny
    translatelocally-models.en-pl-tiny
    translatelocally-models.en-fr-tiny
    translatelocally-models.en-et-tiny
    translatelocally-models.en-es-tiny
    translatelocally-models.en-de-tiny
    translatelocally-models.en-de-base
    translatelocally-models.en-cs-tiny
    translatelocally-models.en-cs-base
    translatelocally-models.en-bg-tiny
    translatelocally-models.el-en-tiny
    translatelocally-models.de-en-tiny
    translatelocally-models.de-en-base
    translatelocally-models.cs-en-tiny
    translatelocally-models.cs-en-base
    translatelocally-models.ca-en-tiny
    translatelocally-models.bg-en-tiny
    translatelocally-models.hbs-eng-tiny
  ];

  stable = with pkgs-stable; [
    # Office
    logseq
    kiwix
    kiwix-tools
    zim
    zim-tools
  ];
in {
  packages = unstable ++ stable;
}
