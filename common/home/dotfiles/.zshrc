if [ -e /bin ]; then
  PATH="$PATH:/bin"
fi

if [ -e /usr/bin ]; then
  PATH="$PATH:/usr/bin"
fi

if [ -e /usr/sbin ]; then
  PATH="$PATH:/usr/sbin"
fi

if [ -e /run/current-system/sw/bin ]; then
  PATH="$PATH:/run/current-system/sw/bin"
fi

if [ -e ~/dev/scripts/remind.sh ]; then
  source ~/dev/scripts/remind.sh
fi

if [ -e /home/reboot/.local/bin ]; then
  PATH="$PATH:~/.local/bin"
fi

if [ -e ~/dev/bin ]; then
  PATH="$PATH:~/dev/bin"
fi

if [ -e ~/bin ]; then
  PATH="$PATH:~/bin"
fi

if [ -e ~/.config/emacs/bin ]; then
  PATH="$PATH:~/.config/emacs/bin"
fi

if command -v plasmashell &> /dev/null; then
	alias restart-plasmashell="killall plasmashell; kstart plasmashell"
fi

if command -v eza &> /dev/null; then
  alias ll="eza -l --icons"
  alias ls="eza --icons"
  alias tree="eza --icons --tree --git-ignore"
fi

if command -v cargo-mommy &> /dev/null; then
  export CARGO_MOMMYS_PRONOUNS="his/their"
  export CARGO_MOMMYS_LITTLE="boy/pup/puppy"
  export CARGO_MOMMYS_ROLES="daddy/master/owner/handler"
  export CARGO_MOMMYS_MOODS="chill/ominous/thirsty/yikes"
  export CARGO_MOMMYS_PARTS="milk/dick/ass/paws/pits/pecs/muscles/musk/piss/balls"
  export CARGO_MOMMYS_FUCKING="slut/toy/pet/pervert/whore/pup/cocksleeve/puppy"

  alias cargo-daddy="cargo-mommy"
fi

if command -v fastfetch &> /dev/null; then
  if command -v fortune &> /dev/null; then
    if command -v lolcat &> /dev/null; then
      alias sclear="clear; fastfetch && fortune | lolcat"
    fi
  fi
fi

if command -v wget &> /dev/null; then
  alias wayback-download="wget --recursive --no-clobber --page-requisites --convert-links --domains web.archive.org --no-parent"
fi

if command -v nix-store &> /dev/null; then
  alias nix-clean="nix-store --gc"
fi

if [ "$SSH_CLIENT" ]; then
  export PINENTRY_USER_DATA=pinentry-curses
fi

unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

PATH="$PATH:."

# hhdfhgh this don't work.
# bindkey  "^[[1~"   beginning-of-line
# bindkey  "^[[4~"   end-of-line
# bindkey  "^[[3~"   delete-char

# Check if this session is interactive (fix `scp` lmao)
if [[ $- == *i* ]]; then
  # Runs tmux on ssh conn, see: https://stackoverflow.com/a/40192494
  if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_TTY" ]]; then
    tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
  fi

  fastfetch
  fortune | lolcat
fi

