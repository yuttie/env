#!/bin/sh

# TeX
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

# Python
PIP3_PACKAGES='pip pipenv awscli pynvim i3-py'
if which pip3 >/dev/null 2>&1; then
  pip3 install --user --upgrade $PIP3_PACKAGES
fi

# Node.js
NPM_PACKAGES='npm vsce heroku neovim'
if which npm >/dev/null 2>&1; then
  for p in $NPM_PACKAGES; do
    npm install -g $p
  done
fi

# Julia
JULIA_PACKAGES='Gadfly CSV Cairo Fontconfig'
if which julia >/dev/null 2>&1; then
  for p in $JULIA_PACKAGES; do
    julia --eval "using Pkg; Pkg.add(\"$p\")"
  done
fi

# Rust
if which rustup >/dev/null 2>&1; then
  rustup self update
  rustup update
  rustup component add rls rust-analysis rust-src
fi

CARGO_PACKAGES_FOR_STABLE='ripgrep xsv exa bat oxipng'
CARGO_PACKAGES_FOR_NIGHTLY='racer'
if which cargo >/dev/null 2>&1; then
  cargo uninstall $CARGO_PACKAGES_FOR_STABLE
  cargo install $CARGO_PACKAGES_FOR_STABLE

  # Run `rustup toolchain install nightly` in advance
  cargo +nightly uninstall $CARGO_PACKAGES_FOR_NIGHTLY
  cargo +nightly install $CARGO_PACKAGES_FOR_NIGHTLY
fi

# Zsh
if which antibody >/dev/null 2>&1; then
  antibody bundle < ~/zdotdir/.zsh_plugins.txt > ~/.zsh_plugins.sh
  antibody update
fi
