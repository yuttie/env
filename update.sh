#!/bin/sh

targets=${@:-tex python nodejs julia rust zsh lensfun}

is_specified() {
  for t in $targets; do
    if [ "$1" = "$t" ]; then
      return 0
    fi
  done
  return 1
}

# TeX
if is_specified tex; then
  for TLMGR in /usr/local/texlive/2019/bin/{x86_64-linux,x86_64-darwin}/tlmgr; do
    if [ -f $TLMGR -a -x $TLMGR ]; then
      break
    else
      TLMGR=''
    fi
  done
  if [ -n "$TLMGR" ]; then
    echo "Found \`tlmgr' at $TLMGR"
    sudo sh -c "$TLMGR update --self; $TLMGR update --all"
  fi
fi

# Python
if is_specified python; then
  PIP3_PACKAGES='pip pipenv awscli pynvim i3-py neovim-remote'
  if which pip3 >/dev/null 2>&1; then
    pip3 install --user --upgrade --force-reinstall $PIP3_PACKAGES
  fi
fi

# Node.js
if is_specified nodejs; then
  NPM_PACKAGES='npm yarn vsce heroku neovim svgo live-server backslide @vue/cli vuepress'
  if which npm >/dev/null 2>&1; then
    for p in $NPM_PACKAGES; do
      npm install -g $p
    done
  fi
fi

# Julia
if is_specified julia; then
  JULIA_PACKAGES='Gadfly CSV Cairo Fontconfig'
  if which julia >/dev/null 2>&1; then
    for p in $JULIA_PACKAGES; do
      julia --eval "using Pkg; Pkg.add(\"$p\")"
    done
  fi
fi

# Rust
if is_specified rust; then
  if which rustup >/dev/null 2>&1; then
    rustup self update
    rustup update
    rustup component add rls rust-analysis rust-src
    rustup target add x86_64-unknown-linux-musl
  fi

  CARGO_PACKAGES_FOR_STABLE='ripgrep fd-find xsv exa bat oxipng'
  CARGO_PACKAGES_FOR_NIGHTLY='racer'
  if which cargo >/dev/null 2>&1; then
    cargo uninstall $CARGO_PACKAGES_FOR_STABLE
    cargo install $CARGO_PACKAGES_FOR_STABLE

    # Run `rustup toolchain install nightly` in advance
    cargo +nightly uninstall $CARGO_PACKAGES_FOR_NIGHTLY
    cargo +nightly install $CARGO_PACKAGES_FOR_NIGHTLY
  fi
fi

# Zsh
if is_specified zsh; then
  if which antibody >/dev/null 2>&1; then
    antibody bundle < ~/zdotdir/.zsh_plugins.txt > ~/.zsh_plugins.sh
    antibody update
  fi
fi

# Lensfun
if is_specified lensfun; then
  lensfun-update-data
fi
