/*
This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
  */
{ pkgs, inputs, ... }:
let 
  secrets = import ./enderger.secret.nix;
  theme = [
    # users/enderger/colors
    "2E3440" # base00
    "3B4252" # base01
    "434C5E" # base02
    "4C566A" # base03
    "D8DEE9" # base04
    "E5E9F0" # base05
    "ECEFF4" # base06
    "8FBCBB" # base07
    "BF616A" # base08
    "D08770" # base09
    "EBCB8B" # base0A
    "A3BE8C" # base0B
    "88C0D0" # base0C
    "81A1C1" # base0D
    "B48EAD" # base0E
    "5E81AC" # base0F
  ];
  font = "FiraCode Nerd Font";
in {
  users.users.enderger = {
    # users/enderger/userOptions
    isNormalUser = true;
    shell = pkgs.nushell;
    group = "wheel";
    extraGroups = [ "docker" ];
    inherit (secrets) hashedPassword;
  };

  services.xserver.windowManager = {
    # users/enderger/windowManagers
    xmonad.enable = true;
    xmonad.enableContribAndExtras = true;
  };

  home-manager.users.enderger = { config, ... }: {
    # CLI setup
    # users/enderger/nushell
    programs.nushell = {
      enable = true;
      settings = {
        complete_from_path = true;
        ctrlc_exit = false;
        disable_table_indexes = false;
        filesize_format = "GiB";
        nonzero_exit_errors = true;
        pivot_mode = "auto";
        prompt = "starship prompt";
        rm_always_trash = true;
        skip_welcome_message = true;
        table_mode = "rounded";

        line_editor = {
          bell_style = "none";
          completion_type = "circular";
          edit_mode = "vi";
          history_duplicates = "ignoreconsecutive";
          history_ignore_space = true;
        };

        textview = {
          tab_width = 2;
          theme = "base16";
        };

        startup = lib.splitString "\n" ''
          # users/enderger/nushell/startup
          pfetch
        '';
      };
    };
    # users/enderger/starship
    programs.starship = {
      enable = true;
      settings = let
        git_color = "bold magenta";
        hg_color = "bold yellow";
      in {
        format = ''
          \[$username$hostname\]$nix_shell$hg_branch$git_status$git_branch$git_commit$git_state
          $character 
        '';
        add_newline = false;

        username = {
          style_root = "bold red";
          style_user = "bold cyan";
          format = "[$user]($style)";

          show_always = true;
        };

        hostname = {
          style = "bold yellow";
          format = "@[$hostname]($style)";

          ssh_only = true;
        };

        nix_shell = {
          style = "bold blue";
          format = " \\([$symbol$state \\($name\\)]($style)\\)";
        };

        hg_branch = {
          style = hg_color;
          format = " [$symbol$branch]($style)";
        };

        git_status = {
          style = git_color;
          format = " [$all_status$ahead_behind]($style)";
        };

        git_branch = {
          style = git_color;
          format = " [$symbol$branch]($style)";
        };

        git_commit = {
          style = git_color;
          format = " \\(commit [$hash( $tag)]($style)\\)";
        };

        git_state = {
          style = git_color;
          format = " [$state( $progress_current/$progress_total)]($style)";
        };

        character = let
          symbol = "λ";
        in {
          success_symbol = "[${symbol}](bold green)";
          error_symbol = "[${symbol}](bold red)";
          vicmd_symbol = "[${symbol}](bold yellow)";
        };
      };
    };
    # users/enderger/alacritty
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "alacritty";
        font.normal.family = font;

        window = {
          decorations = "none";
          title = "Terminal Emulator (Alacritty)";
          dynamic_title = false;
        };

        colors = let
          mkColor = id: "0x${builtins.elemAt colors id}";
        in {
          primary.background = mkColor 0;
          primary.foreground = mkColor 5;

          cursor.text = mkColor 0;
          cursor.cursor = mkColor 5;

          normal = {
            black = mkColor 0;
            red = mkColor 8;
            green = mkColor 11;
            yellow = mkColor 10;
            blue = mkColor 13;
            magenta = mkColor 14;
            cyan = mkColor 12;
            white = mkColor 5;
          };

          bright = {
            black = mkColor 3;
            red = mkColor 8;
            green = mkColor 1;
            yellow = mkColor 2;
            blue = mkColor 4;
            magenta = mkColor 6;
            cyan = mkColor 15;
            white = mkColor 7;
          };
        };
        background_opacity = 0.95;
      };
    };
    # users/enderger/man
    programs.man.enable = true;
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "base16";
      };
    };
    # users/enderger/neovim
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      
      plugins = with pkgs.vimPlugins; [
        # users/enderger/neovim/plugins.backend
        completion-nvim
        neoformat
        nvim-lspconfig
        # this loads all tree-sitter grammars
        (nvim-treesitter.withPlugins builtins.attrValues)
        telescope-nvim
        vim-vsnip vim-vsnip-integ
        which-key-nvim
        # users/enderger/neovim/plugins.editing
        conjure
        lightspeed-nvim
        nvim-autopairs
        nvim-treesitter-refactor
        supertab
        vim-surround
        # users/enderger/neovim/plugins.utilities
        auto-session
        friendly-snippets
        lsp-rooter-nvim
        minimap-vim
        nvim-treesitter-context
        nvim-treesitter-pyfold
        nvim-ts-rainbow
        # users/enderger/neovim/plugins.integrations
        gitsigns-nvim
        glow-nvim
        neogit
        nvim-toggleterm-lua
        vim-test
        # users/enderger/neovim/plugins.ui
        galaxyline-nvim
        nvim-base16
        nvim-lightbulb
        nvim-web-devicons nvim-nonicons
      ];

      extraPackages = with pkgs; [
        # users/enderger/neovim/plugins/packages
        rnix-lsp
        (with fenix; combine [
          default.rustfmt-preview default.clippy rust-analyzer
        ])
        zig zls
      ];
      
      luaInit = "init";
      luaModules = {
        # users/enderger/neovim/config
        init = ''
          -- users/enderger/neovim/config/init
          require('editor')
          require('keys')
          require('editing')
        '';
        preferences = ''
          -- users/enderger/neovim/config/preferences
          local prefs = {}

          prefs.tabSize = 2
          prefs.leader = ' '
          prefs.localLeader = ','

          return prefs
        '';
        lib = ''
          -- users/enderger/neovim/config/lib
          local lib = {};

          function lib.autocmd(event, action, filter='*')
            vim.cmd(string.format("autocmd %s %s %s", event, filter, action))
          end

          return lib
        '';
        editor = ''
          -- users/enderger/neovim/config/editor
          local opt = vim.opt
          local prefs = require('preferences')

          -- asthetic
          opt.background = 'dark'
          opt.cursorline = true
          opt.number = true
          opt.showmode = false
          opt.signcolumn = 'yes:3'

          -- indentation
          opt.expandtab = true
          opt.shiftwidth = prefs.tabSize
          opt.smartindent = true
          opt.tabstop = prefs.tabSize

          -- misc
          opt.confirm = true
          opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
          opt.mouse = 'a'
          opt.spell = true
          opt.title = true
        '';
        keys = ''
          -- users/enderger/neovim/config/keys
          error('Not yet implemented!')
        '';

        editing = ''
  <<<users/enderger/neovim/config/completions>>>
        '';
        tweaks = ''
  <<<users/enderger/neovim/config/utils>>>
        '';
        ui = ''
  <<<users/enderger/neovim/config/ui>>>
        '';
      };
    };
    # users/enderger/git
    programs.git = {
      enable = true;
      userEmail = "endergeryt@gmail.com";
      userName = "Enderger";
    };

    # GUI Setup
    <<<users/enderger/xmonad>>>
    <<<users/enderger/xmobar>>>
    <<<users/enderger/rofi>>>
    <<<users/enderger/qutebrowser>>>

    # Packages
    home.packages = [
      <<<users/enderger/packages>>>
    ];
  };
}
