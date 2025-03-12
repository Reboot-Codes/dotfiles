{
  enable = true;
  
  settings = {
    general.live_config_reload = true;
  
    bell = {
      animation = "EaseOutExpo";
      color = "0x555555";
      duration = 200;
    };
  
    colors = {
      bright = {
        black = "#928374";
        blue = "#83a598";
        cyan = "#8ec07c";
        green = "#b8bb26";
        magenta = "#d3869b";
        red = "#fb4934";
        white = "#ebdbb2";
        yellow = "#fabd2f";
      };
  
      normal = {
        black = "#282828";
        blue = "#458588";
        cyan = "#689d6a";
        green = "#98971a";
        magenta = "#b16286";
        red = "#cc241d";
        white = "#a89984";
        yellow = "#d79921";
      };
  
      primary = {
        background = "#000000";
        foreground = "#ffffff";
      };
    };
  
    cursor.style = "Beam";
  
    env = {
      "TERM" = "xterm-256color";
    };
  
    font = {
      size = 10.0;
  
      bold = {
        family = "JetBrainsMono NF ExtraBold";
        style = "Normal";
      };
  
      bold_italic = {
        family = "JetBrainsMono NF ExtraBold";
        style = "Italic";
      };
  
      italic = {
        family = "JetBrainsMono NF Medium";
        style = "Italic";
      };
  
      normal = {
        family = "JetBrainsMono NF Medium";
        style = "Normal";
      };
    };
  
    scrolling = {
      history = 100000;
      multiplier = 1;
    };
  
    selection = {
      save_to_clipboard = true;
      semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
    };
  
    terminal.shell = {
      args = ["-l" "-c" "tmux attach || tmux"];
      program = "zsh";
    };
  };
}
