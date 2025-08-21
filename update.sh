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
  for TLMGR in /usr/local/texlive/2025/bin/{x86_64-linux,x86_64-darwin}/tlmgr; do
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
  UV_PACKAGES='
    basedpyright
    jedi-language-server
    poetry
    python-lsp-server
    ruff
  '
  if command -v uv >/dev/null 2>&1; then
    for p in $UV_PACKAGES; do
      uv tool install $p
    done
    uv tool upgrade --all
  fi
  if command -v poetry >/dev/null 2>&1; then
    poetry completions fish > ~/.config/fish/completions/poetry.fish
    poetry completions zsh > ~/.zfunc/_poetry
  fi
fi

# Node.js
if is_specified nodejs; then
  NPM_PACKAGES='
    backslide
    bash-language-server
    decktape
    dockerfile-language-server-nodejs
    json-schema-to-typescript
    live-server
    neovim
    sql-language-server
    svgo
    typescript
    typescript-language-server
    vim-language-server
    vsce
    vscode-langservers-extracted
    @vue/cli
    @vue/language-server@2
    @vue/typescript-plugin@2
  '
  if command -v npm >/dev/null 2>&1; then
    NPM_CONFIG_LOGLEVEL=error npm install --global --no-fund --no-audit $NPM_PACKAGES
    NPM_CONFIG_LOGLEVEL=error npm upgrade --global --no-fund --no-audit
  fi
fi

# Julia
if is_specified julia; then
  JULIA_PACKAGES='
    Cairo
    CSV
    Fontconfig
    Gadfly
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
    github.com/dinedal/textql/...@latest
    github.com/itchyny/mmv/cmd/mmv@latest
    github.com/rhysd/vim-startuptime@latest
    github.com/simeji/jid/cmd/jid@latest
    github.com/tomnomnom/gron@latest
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

  # NOTE Some packages are installed via OS managers
  # - bat
  # - eza
  # - fd-find
  # - git-delta
  # - hyperfine
  # - ripgrep
  # - starship
  # - watchexec-cli
  # - websocat
  # - xsv
  CARGO_PACKAGES_FOR_STABLE='
    bacon
    bandwhich
    binocle
    broot
    cargo-generate
    deno
    diskus
    dprint
    drill
    dua-cli
    du-dust
    evcxr_repl
    fselect
    git-cliff
    grex
    hexyl
    monolith
    navi
    nu
    numbat-cli
    oxipng
    pastel
    procs
    pueue
    py-spy
    qsv
    ripgrep_all
    rust-script
    sd
    sqlx-cli
    systemfd
    tealdeer
    teip
    vivid
    wasm-pack
    xan
    xh
    zellij
  '
  CARGO_PACKAGES_FROM_GIT_URL_FOR_STABLE='
    https://github.com/latex-lsp/texlab
    https://github.com/neovide/neovide
  '
  CARGO_PACKAGES_FOR_STABLE_J1=''
  CARGO_PACKAGES_FOR_NIGHTLY=''

  # Enable -O3
  export COMMON_FLAGS="-march=native -O3 -pipe"
  export CFLAGS="${COMMON_FLAGS}"
  export CXXFLAGS="${COMMON_FLAGS}"
  export RUSTFLAGS="-C target-cpu=native -C opt-level=3"

  if command -v cargo >/dev/null 2>&1; then
    if [ -n "$CARGO_PACKAGES_FOR_STABLE" ]; then
      for pkg in $CARGO_PACKAGES_FOR_STABLE; do
        echo -n "Installing $pkg: "
        cargo install --locked --quiet $pkg && echo "$(tput setaf 10)OK$(tput sgr0)" || echo "$(tput setaf 9)Error: $?$(tput sgr0)"
      done
    fi

    if [ -n "$CARGO_PACKAGES_FOR_STABLE_J1" ]; then
      for pkg in $CARGO_PACKAGES_FOR_STABLE_J1; do
        echo -n "Installing $pkg: "
        cargo install --locked --quiet -j1 $pkg && echo "$(tput setaf 10)OK$(tput sgr0)" || echo "$(tput setaf 9)Error: $?$(tput sgr0)"
      done
    fi

    # Run `rustup toolchain install nightly` in advance
    if [ -n "$CARGO_PACKAGES_FOR_NIGHTLY" ]; then
      for pkg in $CARGO_PACKAGES_FOR_NIGHTLY; do
        echo -n "Installing $pkg: "
        cargo +nightly install --locked --quiet $pkg && echo "$(tput setaf 10)OK$(tput sgr0)" || echo "$(tput setaf 9)Error: $?$(tput sgr0)"
      done
    fi

    if [ -n "$CARGO_PACKAGES_FROM_GIT_URL_FOR_STABLE" ]; then
      for url in $CARGO_PACKAGES_FROM_GIT_URL_FOR_STABLE; do
        pkg="${url##*/}"
        echo -n "Installing $pkg: "
        cargo install --locked --quiet --git $url && echo "$(tput setaf 10)OK$(tput sgr0)" || echo "$(tput setaf 9)Error: $?$(tput sgr0)"
      done
    fi

    url="https://github.com/astral-sh/uv"
    pkg="uv"
    echo -n "Installing $pkg: "
    cargo install --quiet --git $url $pkg && echo "$(tput setaf 10)OK$(tput sgr0)" || echo "$(tput setaf 9)Error: $?$(tput sgr0)"
  fi

  unset COMMON_FLAGS CFLAGS CXXFLAGS RUSTFLAGS
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
