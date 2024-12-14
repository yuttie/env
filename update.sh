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
  PIPX_PACKAGES='
    poetry
    basedpyright
    jedi-language-server
    python-lsp-server
    ruff
  '
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
  NPM_PACKAGES='
    bash-language-server
    vscode-langservers-extracted
    dockerfile-language-server-nodejs
    sql-language-server
    typescript
    typescript-language-server
    vim-language-server
    vls
    vsce
    neovim
    svgo
    live-server
    backslide
    decktape
    @vue/cli
  '
  if command -v npm >/dev/null 2>&1; then
    NPM_CONFIG_LOGLEVEL=error npm install --global --no-fund --no-audit $NPM_PACKAGES
    NPM_CONFIG_LOGLEVEL=error npm upgrade --global --no-fund --no-audit
  fi
fi

# Julia
if is_specified julia; then
  JULIA_PACKAGES='
    Gadfly
    CSV
    Cairo
    Fontconfig
  '
  if command -v julia >/dev/null 2>&1; then
    for p in $JULIA_PACKAGES; do
      julia --eval "using Pkg; Pkg.add(\"$p\")"
    done
  fi
fi

# Go
if is_specified go; then
  GO_PACKAGES='
    github.com/rhysd/vim-startuptime@latest
    github.com/dinedal/textql/...@latest
    github.com/simeji/jid/cmd/jid@latest
    github.com/tomnomnom/gron@latest
    github.com/itchyny/mmv/cmd/mmv@latest
  '
  if command -v go >/dev/null 2>&1; then
    export CGO_CFLAGS="-march=native -O3 -pipe"
    export CGO_CXXFLAGS="-march=native -O3 -pipe"
    export CGO_FFLAGS="-march=native -O3 -pipe"
    export GOAMD64="v3"
    for p in $GO_PACKAGES; do
      go install "$p"
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

  CARGO_PACKAGES_FOR_STABLE='
    wasm-pack
    cargo-generate
    deno
    oxipng
    pastel
    procs
    fselect
    broot
    sd
    teip
    monolith
    grex
    evcxr_repl
    drill
    pueue
    tealdeer
    bandwhich
    xh
    py-spy
    ripgrep_all
    rust-script
    zellij
  '
  CARGO_PACKAGES_FROM_GIT_URL_FOR_STABLE='
    https://github.com/latex-lsp/texlab
    https://github.com/neovide/neovide
  '
  CARGO_PACKAGES_FOR_STABLE_J1=''
  CARGO_PACKAGES_FOR_NIGHTLY=''
  if command -v cargo >/dev/null 2>&1; then
    if [ -n "$CARGO_PACKAGES_FOR_STABLE" ]; then
      cargo uninstall --quiet $CARGO_PACKAGES_FOR_STABLE
      for pkg in $CARGO_PACKAGES_FOR_STABLE; do
        echo -n "Installing $pkg: "
        cargo install --locked --quiet $pkg && echo "OK" || echo "Error: $?"
      done
    fi

    if [ -n "$CARGO_PACKAGES_FOR_STABLE_J1" ]; then
      cargo uninstall --quiet $CARGO_PACKAGES_FOR_STABLE_J1
      for pkg in $CARGO_PACKAGES_FOR_STABLE_J1; do
        echo -n "Installing $pkg: "
        cargo install --locked --quiet -j1 $pkg && echo "OK" || echo "Error: $?"
      done
    fi

    # Run `rustup toolchain install nightly` in advance
    if [ -n "$CARGO_PACKAGES_FOR_NIGHTLY" ]; then
      cargo +nightly uninstall --quiet $CARGO_PACKAGES_FOR_NIGHTLY
      for pkg in $CARGO_PACKAGES_FOR_NIGHTLY; do
        echo -n "Installing $pkg: "
        cargo +nightly install --locked --quiet $pkg && echo "OK" || echo "Error: $?"
      done
    fi

    if [ -n "$CARGO_PACKAGES_FROM_GIT_URL_FOR_STABLE" ]; then
      for url in $CARGO_PACKAGES_FROM_GIT_URL_FOR_STABLE; do
        pkg="${url##*/}"
        cargo uninstall --quiet $pkg
        echo -n "Installing $pkg: "
        cargo install --locked --quiet --git $url && echo "OK" || echo "Error: $?"
      done
    fi
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
