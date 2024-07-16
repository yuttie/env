#!/bin/sh

targets=${@:-tex python nodejs julia go rust fish zsh lensfun}

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
  for TLMGR in /usr/local/texlive/2024/bin/{x86_64-linux,x86_64-darwin}/tlmgr; do
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
  PIPX_PACKAGES='poetry jedi-language-server maturin'
  if command -v pipx >/dev/null 2>&1; then
    for p in $PIPX_PACKAGES; do
      pipx install $p
    done
    pipx upgrade-all
  fi
  if command -v poetry >/dev/null 2>&1; then
    poetry completions fish > ~/.config/fish/completions/poetry.fish
    poetry completions zsh > ~/.zfunc/_poetry
  fi
fi

# Node.js
if is_specified nodejs; then
  YARN_PACKAGES='pyright bash-language-server vscode-langservers-extracted dockerfile-language-server-nodejs sql-language-server typescript-language-server vim-language-server vls vsce neovim svgo live-server backslide decktape @vue/cli vuepress docsify-cli'
  if command -v yarn >/dev/null 2>&1; then
    yarn global add $YARN_PACKAGES
    yarn global upgrade
    rm -fv $HOME/.yarn/bin/watch
  fi
fi

# Julia
if is_specified julia; then
  JULIA_PACKAGES='Gadfly CSV Cairo Fontconfig'
  if command -v julia >/dev/null 2>&1; then
    for p in $JULIA_PACKAGES; do
      julia --eval "using Pkg; Pkg.add(\"$p\")"
    done
  fi
fi

# Go
if is_specified go; then
  GO_PACKAGES='github.com/dinedal/textql/... github.com/simeji/jid/cmd/jid github.com/tomnomnom/gron github.com/itchyny/mmv/cmd/mmv'
  if command -v go >/dev/null 2>&1; then
    for p in $GO_PACKAGES; do
      go get -u "$p"
    done
  fi
fi

# Rust
if is_specified rust; then
  if command -v rustup >/dev/null 2>&1; then
    rustup self update
    rustup update
    rustup toolchain add nightly
    rustup target add x86_64-unknown-linux-musl
    rustup target add wasm32-unknown-unknown
    rustup component add rust-analyzer rust-src clippy rustfmt
    rustup component add rustfmt --toolchain nightly
  fi

  CARGO_PACKAGES_FOR_STABLE='wasm-pack cargo-generate oxipng pastel procs broot sd teip evcxr_repl drill pueue tealdeer bandwhich xh py-spy ripgrep_all rust-script zellij'
  CARGO_PACKAGES_FOR_STABLE_J1='deno'
  CARGO_PACKAGES_FOR_NIGHTLY=''
  if command -v cargo >/dev/null 2>&1; then
    if [ -n "$CARGO_PACKAGES_FOR_STABLE" ]; then
      cargo uninstall $CARGO_PACKAGES_FOR_STABLE
      cargo install --locked $CARGO_PACKAGES_FOR_STABLE
    fi

    if [ -n "$CARGO_PACKAGES_FOR_STABLE_J1" ]; then
      cargo uninstall $CARGO_PACKAGES_FOR_STABLE_J1
      cargo install --locked -j1 $CARGO_PACKAGES_FOR_STABLE_J1
    fi

    # Run `rustup toolchain install nightly` in advance
    if [ -n "$CARGO_PACKAGES_FOR_NIGHTLY" ]; then
      cargo +nightly uninstall --quiet $CARGO_PACKAGES_FOR_NIGHTLY
      cargo +nightly install --locked --quiet $CARGO_PACKAGES_FOR_NIGHTLY
    fi

    # Packages which need special treatment
    cargo uninstall texlab
    cargo install --locked --git https://github.com/latex-lsp/texlab.git
  fi
fi

# Fish
if is_specified fish; then
  if command -v fish >/dev/null 2>&1; then
    fish -c 'fisher update'
  fi
fi

# Zsh
if is_specified zsh; then
  if command -v antibody >/dev/null 2>&1; then
    antibody bundle < ~/zdotdir/.zsh_plugins.txt > ~/.zsh_plugins.sh
    antibody update
  fi
fi

# Lensfun
if is_specified lensfun; then
  lensfun-update-data
fi
