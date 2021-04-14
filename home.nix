{ config, pkgs, ... }:

let
  vim-ormolu = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-ormolu";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "sdiehl";
      repo = "vim-ormolu";
      rev = "0376ced83569994066c61827ad2160449033c509";
      sha256 = "1ga5r24yymqcgjizqyaz6fxl2b8vp66ggzqa63pwl5qdp0rm97b8";
    };
  };

  zsh-plugins = {
    nix-shell = (fetchGit {
      url = "https://github.com/chisui/zsh-nix-shell.git";
      rev = "69e90b9bccecd84734948fb03087c2454a8522f6";
    });

    nix-zsh-completions = (fetchGit {
      url = "https://github.com/spwhitt/nix-zsh-completions.git";
      rev = "d9f48b9be5d7ef8b0cfb43e08f9dd820d9e125ac";
    });

    zsh-vi-mode = (fetchGit {
      url = "https://github.com/jeffreytse/zsh-vi-mode.git";
      rev = "18727a0cabed4acbf72e8e1cc1457e8d647fee16";
    });
  };

  pursPkgs = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "3b4039475c245243716b1e922455a9062c0531da";
    sha256 = "0fk2r02z86rirg5kggd0vvcgp8h07w7fhp03xng7wjrifljxwann";
  }) { inherit pkgs; };

  simPkgs = import /Users/peter/Code/portal-suite/nix/pkgs {};

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "peter";
  home.homeDirectory = "/Users/peter";
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.file = {
    ".config/starship.toml".source = ./starship.toml;
    ".zsh/custom/plugins/nix-shell".source = zsh-plugins.nix-shell;
    ".zsh/custom/plugins/nix-zsh-completions".source = zsh-plugins.nix-zsh-completions;
    ".zsh/custom/plugins/zsh-vi-mode".source = zsh-plugins.zsh-vi-mode;
  };
  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  home.packages = [
    # pkgs.texlive.combined.scheme-full
    # pkgs.vscode-with-extensions

    # Not sure how to get these to sym-link to Applications folder?
    # pkgs.docker
    # pkgs.iterm2
    # pkgs.slack
    # pkgs.vlc

    pkgs.bat
    pkgs.bottom
    pkgs.coreutils
    pkgs.dhall
    pkgs.dhall-lsp-server
    pkgs.dust
    pkgs.elmPackages.elm
    pkgs.exa
    pkgs.fd
    pkgs.ffmpeg
    pkgs.ghc
    pkgs.ghcid
    pkgs.git
    pkgs.gnumake
    pkgs.gnused
    pkgs.graphviz
    pkgs.haskellPackages.implicit-hie
    pkgs.htop
    pkgs.imagemagick
    pkgs.inkscape
    pkgs.jq
    pkgs.kubernetes
    pkgs.kubernetes-helm
    pkgs.nerdfonts
    pkgs.nix-prefetch-git
    pkgs.nodePackages.parcel-bundler
    pkgs.nodejs
    pkgs.ormolu
    pkgs.pandoc
    pkgs.pass
    pkgs.ripgrep
    pkgs.stack
    pkgs.texlive.combined.scheme-small
    pkgs.tokei
    pkgs.trash-cli
    pkgs.tree
    pkgs.vscode
    pkgs.watch
    pkgs.xsv
    pkgs.youtube-dl
    pkgs.zoxide
    pkgs.zstd

    pursPkgs.purs
    pursPkgs.purty
    pursPkgs.spago

    simPkgs.minio
    simPkgs.nodejs
    simPkgs.postgresqlWithPackages
    simPkgs.yarn
  ];
  
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      coc-nvim
      ctrlp-vim
      fzf-vim
      fzfWrapper
      nerdtree
      vim-airline
      vim-airline-themes
      vim-colorschemes
      vim-commentary
      vim-nix
      vim-ormolu
      vim-polyglot
      vim-surround
    ];
    extraPackages = [
      # pkgs.nodejs # Needed for coc-nvim
    ];

    extraConfig = ''
      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
    '';
  };

  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "${pkgs.ripgrep}/bin/rg --files";
  };

  programs.gpg = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    keyMode = "vi";
    shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";
    terminal = "screen-256color";
    extraConfig = ''
      # For the italics
      # set -g default-terminal "tmux-256color"
      # set -as terminal-overrides ',xterm*:sitm=\E[3m'
      
      # Changes cursor to horizontal bar in insert mode
      set -g -a terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'
      
      # No delay switching modes in vim
      set -sg escape-time 0
      
      # No delay for repeating commands (ie, arrows for switching panes)
      set-option -g repeat-time 0
      
      # Theme for status bar
      set -g status-position bottom
      set -g status-justify left
      set -g status-left-length 30
      set -g status-left ""
      set -g status-right ""
      set -g status-style fg=colour12,bg=colour18,dim

      setw -g window-status-current-style fg=colour1,bg=colour19,bold
      setw -g window-status-current-format ' #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '
      
      # Mouse on
      # set -g mouse on
      
      # Copying to clipboard
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
      
      setw -g window-status-style fg=colour20,bg=colour18,none
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
      
      # Open new panes in current path
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      
      # Vi bindings for switching panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  }; 

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    history = {
      ignoreSpace = true;
      ignoreDups = true;
    };
    oh-my-zsh = {
      enable = true;
      custom = "$HOME/.zsh/custom/";
      plugins = [
        "git"
        "nix-zsh-completions"
        "nix-shell"
        # "zsh-vi-mode" <- Doesn't play well with fzf
      ];
    };
    shellAliases = {
      ls = "exa";
    };

    initExtraBeforeCompInit = ''
      eval "$(zoxide init zsh)"
    '';

    initExtra = ''
      # Edit line in vim with ctrl-e:
      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line
    '';

    envExtra = ''
      export XDG_CONFIG_HOME=$HOME/.config
      export GPG_TTY=$(tty)
      source <(/usr/local/bin/kustomize completion zsh)
    '';
  };
}
