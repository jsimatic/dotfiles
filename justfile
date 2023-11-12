this_dir := justfile_directory()
home := env_var('HOME')
omz_plugin_dir := home / ".oh-my-zsh/custom/plugins"
post_install := "post_install.sh"
zshrc := home / ".zshrc"

# Display available targets (default target)
help:
  @just --list

# All install
all:
    rm -f {{post_install}}
    just omz_install
    just add_completion_plugin "just" "just --completions zsh"
    just rye_tools
    just cargo_tools
    just fzf
    just omz_plugins
    just dotfile aliasrc
    just confdir i3
    just refactor_post_install
    @echo "🎉 Done"
    @echo "To complete the installation, run: source {{post_install}}" 

[private]
refactor_post_install:
    #!/usr/bin/env sh
    plugins=$(grep "omz plugin enable" {{post_install}} | cut -d" " -f4 | tr '\n' ' ')
    echo "source ~/.aliasrc" > {{post_install}}
    echo "omz plugin enable \"$plugins\"" >> {{post_install}}
    echo "omz reload" >> {{post_install}}

# Install the dotfile stem as ~/.stem
dotfile stem:
    ln -sb {{this_dir}}/{{stem}} {{home}}/.{{stem}}

# Install the contents stem/* in ~/.config/stem/
confdir stem:
    mkdir -p {{home}}/.config/{{stem}}
    @for file in `ls {{stem}}`; do \
        cmd="ln -sb {{this_dir}}/{{stem}}/$file {{home}}/.config/{{stem}}/$file"; \
        echo $cmd; \
        $cmd; \
    done

# Install Oh-My-Zsh
omz_install:
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# Add a completion config for prog by running cmd
add_completion_plugin prog cmd:
    mkdir -p {{omz_plugin_dir}}/{{prog}}
    {{cmd}} > {{omz_plugin_dir}}/{{prog}}/_{{prog}}
    echo "omz plugin enable {{prog}}" >> {{post_install}}

# Instal pkg with cargo
rye:
    cargo install --git https://github.com/mitsuhiko/rye rye
    just add_completion_plugin "rye" "rye self completion -s zsh"
    rye config --set-bool behavior.global-python=true

# Global python tools
rye_tools: rye
    rye install -f black
    rye install -f hatch
    rye install -f ruff
    rye install -f thefuck
    echo "omz plugin enable thefuck" >> {{post_install}}

# Install starship
cargo_tools: (nerdfont "FiraCode")
    PROFILE=/dev/null cargo install starship
    echo "omz plugin enable starship" >> {{post_install}}
    cargo install fd-find
    echo "omz plugin enable fd" >> {{post_install}}
    cargo install bat
    cargo install du-dust 
    cargo install tlrc 
    cargo install ripgrep
    echo "omz plugin enable ripgrep" >> {{post_install}}
    cargo install zoxide
    echo "omz plugin enable zoxide" >> {{post_install}}

# Additional OMZ plugins
omz_plugins:
    echo "omz plugin enable rust" >> {{post_install}}
    echo "omz plugin enable vscode" >> {{post_install}}
    echo "omz plugin enable ssh-agent" >> {{post_install}}

fzf:
    rm -rf  {{home}}/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git {{home}}/.fzf
    echo "omz plugin enable fzf" >> {{post_install}}

nerdfont_url := "https://github.com/ryanoasis/nerd-fonts/releases/download"
nerdfont_version := "v3.0.2"
font_dir := home / ".local/share/fonts"

# Install a NerdFont variant of font
nerdfont font:
    mkdir -p {{font_dir}}
    curl -sSfL {{nerdfont_url}}/{{nerdfont_version}}/{{font}}.tar.xz | tar -xJ -C {{font_dir}}

nvm_url := "https://raw.githubusercontent.com/nvm-sh/nvm/"
nvm_version := "v0.39.5"
[private]
npm version:
    PROFILE=/dev/null bash -c 'curl -o- {{nvm_url}}/{{nvm_version}}/install.sh | bash'
    . "{{home}}/.nvm/nvm.sh"; nvm install {{version}}
    echo "omz plugin enable nvm" >> {{post_install}}

# Install inshellisense
inshellisense: (npm "20")
    npm install -g @microsoft/inshellisense
    grep -q "inshellisense" {{zshrc}} || \
    echo "[ -f ~/.inshellisense/key-bindings.zsh ] && source ~/.inshellisense/key-bindings.zsh" >> {{zshrc}}