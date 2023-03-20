### OH MY ZSH ###

if [ "$(basename -- "$ZSH")" = ".oh-my-zsh" ]; then
    echo ""
    echo " Oh My Zsh seems to already be here. Skipping install. Does it need updating?"
else
    # retrieve oh-my-zsh https://ohmyz.sh/#install
    curl --fail --silent --show-error --location \
        --output tmp_install_ohmyzsh.sh \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh

    # install oh-my-zsh
    sh tmp_install_ohmyzsh.sh --unattended
fi

zsh_syntax_highlighting_location=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
if [ -d "${zsh_syntax_highlighting_location}" ]; then
    echo "\n zsh syntax highlighting plugin already present. Skipping clone. Does it need updating?"
else
    git clone --depth=1 \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "${zsh_syntax_highlighting_location}"
    echo "\n Update ~/.zshrc with 'plugins=(... zsh-syntax-highlighting)' to enable it."
fi

### Powerlevel 10k ###

# retrieve powerlevel10k https://github.com/romkatv/powerlevel10k
p10k_theme_location=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
if [ -d "${p10k_theme_location}" ]; then
    echo "\n Powerlevel10k theme already present. Skipping clone. Does it need updating?"
else
    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "${p10k_theme_location}"
fi

# retrieve recommended fonts
styles=( "Regular" "Bold" "Italic" "Bold%20Italic" )
for style in "${styles[@]}"
do
    remote_name="MesloLGS%20NF%20${style}.ttf"
    local_name="$(echo ${remote_name} | sed 's/%20/ /g')"
    local_font_location="${HOME}/Library/Fonts/${local_name}"
    if [ -f "${local_font_location}" ]; then
        echo "\n We've already got ${local_name}. Skipping download."
    else
        curl --fail --silent --show-error --location \
            --output "${HOME}/Library/Fonts/${local_name}" \
            "https://github.com/romkatv/powerlevel10k-media/raw/master/${remote_name}"
    fi
done

if [ "$(basename -- "$SHELL")" != "zsh" ]; then
    echo "\n Hey, you're gonna want to switch your shell to zsh for any of this to take effect."
fi

echo ""
echo " Set ZSH_THEME='powerlevel10k/powerlevel10k' in ~/.zshrc"
echo " ... then restart zsh with 'exec zsh' or open a new terminal window"
echo " ... then run 'p10k configure' if the setup wizard didn't start automatically."
