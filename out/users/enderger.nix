/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ pkgs, inputs, lib, system, ... }:
let 
  secrets = import ./enderger.secret.nix;
  theme = [
    # users/enderger/colours
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
  
  theme-colour = builtins.elemAt theme;
  font = {
    name = "FiraCode Nerd Font";
    package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
    size = 11;
  };
  term = "alacritty";
  browser = "qutebrowser";
  lock = "${pkgs.i3lock}/bin/i3lock -n -c ${theme-colour 0}";
  editor = "emacsclient";
in {
  # users/enderger/userOptions
  environment.shells = [ pkgs.nushell ];
  users.users.enderger = {
    isNormalUser = true;
    shell = pkgs.nushell;
    group = "wheel";
    extraGroups = [ "docker" "libvirt" ];
    inherit (secrets) hashedPassword;
  };

  services.xserver.windowManager = {
    # users/enderger/windowManagers
    awesome = {
        enable = true;
        package = pkgs.awesome-master;
    };
  };

  home-manager.users.enderger = { config, ... }: {
    # CLI setup
    # users/enderger/nushell

    programs.nushell = {
        enable = true;
        envFile.text = ''
    # Nushell Environment Config File

    def create_left_prompt [] {
        let path_segment = ($env.PWD)

        $path_segment
    }

    def create_right_prompt [] {
        let time_segment = ([
            (date now | date format '%m/%d/%Y %r')
        ] | str collect)

        $time_segment
    }

    # Use nushell functions to define your right and left prompt
    let-env PROMPT_COMMAND = { create_left_prompt }
    let-env PROMPT_COMMAND_RIGHT = { create_right_prompt }

    # The prompt indicators are environmental variables that represent
    # the state of the prompt
    let-env PROMPT_INDICATOR = { "〉" }
    let-env PROMPT_INDICATOR_VI_INSERT = { ": " }
    let-env PROMPT_INDICATOR_VI_NORMAL = { "〉" }
    let-env PROMPT_MULTILINE_INDICATOR = { "::: " }

    # Specifies how environment variables are:
    # - converted from a string to a value on Nushell startup (from_string)
    # - converted from a value back to a string when running external commands (to_string)
    # Note: The conversions happen *after* config.nu is loaded
    let-env ENV_CONVERSIONS = {
      "PATH": {
        from_string: { |s| $s | split row (char esep) }
        to_string: { |v| $v | str collect (char esep) }
      }
      "Path": {
        from_string: { |s| $s | split row (char esep) }
        to_string: { |v| $v | str collect (char esep) }
      }
    }

    # Directories to search for scripts when calling source or use
    #
    # By default, <nushell-config-dir>/scripts is added
    let-env NU_LIB_DIRS = [
        ($nu.config-path | path dirname | path join 'scripts')
    ]

    # Directories to search for plugin binaries when calling register
    #
    # By default, <nushell-config-dir>/plugins is added
    let-env NU_PLUGIN_DIRS = [
        ($nu.config-path | path dirname | path join 'plugins')
    ]

    # To add entries to PATH (on Windows you might use Path), you can use the following pattern:
    # let-env PATH = ($env.PATH | prepend '/some/path')
        '';
        configFile.text = ''
      # TODO: Completions
      module completions {
        # Custom completions for external commands (those outside of Nushell)
        # Each completions has two parts: the form of the external command, including its flags and parameters
        # and a helper command that knows how to complete values for those flags and parameters
        #
        # This is a simplified version of completions for git branches and git remotes
        def "nu-complete git branches" [] {
          ^git branch | lines | each { |line| \$line | str replace '[\*\+] ' "" | str trim }
        }
      
        def "nu-complete git remotes" [] {
          ^git remote | lines | each { |line| \$line | str trim }
        }
      
        export extern "git checkout" [
          branch?: string@"nu-complete git branches" # name of the branch to checkout
          -b: string                                 # create and checkout a new branch
          -B: string                                 # create/reset and checkout a branch
          -l                                         # create reflog for new branch
          --guess                                    # second guess 'git checkout <no-such-branch>' (default)
          --overlay                                  # use overlay mode (default)
          --quiet(-q)                                # suppress progress reporting
          --recurse-submodules: string               # control recursive updating of submodules
          --progress                                 # force progress reporting
          --merge(-m)                                # perform a 3-way merge with the new branch
          --conflict: string                         # conflict style (merge or diff3)
          --detach(-d)                               # detach HEAD at named commit
          --track(-t)                                # set upstream info for new branch
          --force(-f)                                # force checkout (throw away local modifications)
          --orphan: string                           # new unparented branch
          --overwrite-ignore                         # update ignored files (default)
          --ignore-other-worktrees                   # do not check if another worktree is holding the given ref
          --ours(-2)                                 # checkout our version for unmerged files
          --theirs(-3)                               # checkout their version for unmerged files
          --patch(-p)                                # select hunks interactively
          --ignore-skip-worktree-bits                # do not limit pathspecs to sparse entries only
          --pathspec-from-file: string               # read pathspec from file
        ]
      
        export extern "git push" [
          remote?: string@"nu-complete git remotes", # the name of the remote
          refspec?: string@"nu-complete git branches"# the branch / refspec
          --verbose(-v)                              # be more verbose
          --quiet(-q)                                # be more quiet
          --repo: string                             # repository
          --all                                      # push all refs
          --mirror                                   # mirror all refs
          --delete(-d)                               # delete refs
          --tags                                     # push tags (can't be used with --all or --mirror)
          --dry-run(-n)                              # dry run
          --porcelain                                # machine-readable output
          --force(-f)                                # force updates
          --force-with-lease: string                 # require old value of ref to be at this value
          --recurse-submodules: string               # control recursive pushing of submodules
          --thin                                     # use thin pack
          --receive-pack: string                     # receive pack program
          --exec: string                             # receive pack program
          --set-upstream(-u)                         # set upstream for git pull/status
          --progress                                 # force progress reporting
          --prune                                    # prune locally removed refs
          --no-verify                                # bypass pre-push hook
          --follow-tags                              # push missing but relevant tags
          --signed: string                           # GPG sign the push
          --atomic                                   # request atomic transaction on remote side
          --push-option(-o): string                  # option to transmit
          --ipv4(-4)                                 # use IPv4 addresses only
          --ipv6(-6)                                 # use IPv6 addresses only
        ]
      }

      module prompt {
          export env STARSHIP_SHELL {"nu"}
          export env PROMPT_COMMAND {{ left_prompt }}
          export env PROMPT_COMMAND_RIGHT {{ right_prompt }}
          export env PROMPT_INDICATOR {""}

          def left_prompt [] {
            starship prompt
          }

          def right_prompt [] {
            ""
          }
      }


      # Get just the extern definitions without the custom completion commands
      use completions *
      use prompt *

      # Direnv Nushell helper
      def-env "direnv nu" [] {
        ^direnv export elvish | from json | load-env
      }

      # Aliases
      alias "nix build-log" = nix build --log-format bar-with-log
      alias "nix prefetch github" = nix-prefetch-github

      def "nixos rebuild" [subcmd flake ...args] {
        nixos-rebuild $subcmd --flake $flake $args
      }

      # for more information on themes see
      # https://www.nushell.sh/book/coloring_and_theming.html
      let default_theme = {
          # color for nushell primitives
          separator: white
          leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
          header: green_bold
          empty: blue
          bool: white
          int: white
          filesize: white
          duration: white
          date: white
          range: white
          float: white
          string: white
          nothing: white
          binary: white
          cellpath: white
          row_index: green_bold
          record: white
          list: white
          block: white
          hints: dark_gray

          # shapes are used to change the cli syntax highlighting
          shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
          shape_binary: purple_bold
          shape_bool: light_cyan
          shape_int: purple_bold
          shape_float: purple_bold
          shape_range: yellow_bold
          shape_internalcall: cyan_bold
          shape_external: cyan
          shape_externalarg: green_bold
          shape_literal: blue
          shape_operator: yellow
          shape_signature: green_bold
          shape_string: green
          shape_string_interpolation: cyan_bold
          shape_datetime: cyan_bold
          shape_list: cyan_bold
          shape_table: blue_bold
          shape_record: cyan_bold
          shape_block: blue_bold
          shape_filepath: cyan
          shape_globpattern: cyan_bold
          shape_variable: purple
          shape_flag: blue_bold
          shape_custom: green
          shape_nothing: light_cyan
      }

      # The default config record. This is where much of your global configuration is setup.
      let \$config = {
        filesize_metric: false
        table_mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        use_ls_colors: true
        rm_always_trash: false
        color_config: \$default_theme
        use_grid_icons: true
        footer_mode: "25" # always, never, number_of_rows, auto
        quick_completions: false  # set this to false to prevent auto-selecting completions when only one remains
        partial_completions: true  # set this to false to prevent partial filling of the prompt
        animate_prompt: false # redraw the prompt every second
        float_precision: 2
        use_ansi_coloring: true
        filesize_format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
        edit_mode: vi # emacs, vi
        max_history_size: 10000 # Session has to be reloaded for this to take effect
        sync_history_on_enter: true # Enable to share the history between multiple sessions, else you have to close the session to persist history to file
        menus: [
            # Configuration for default nushell menus
            # Note the lack of souce parameter
            {
              name: completion_menu
              only_buffer_difference: false
              marker: "| "
              type: {
                  layout: columnar
                  columns: 4
                  col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                  col_padding: 2
              }
              style: {
                  text: green
                  selected_text: green_reverse
                  description_text: yellow
              }
            }
            {
              name: history_menu
              only_buffer_difference: true
              marker: "? "
              type: {
                  layout: list
                  page_size: 10
              }
              style: {
                  text: green
                  selected_text: green_reverse
                  description_text: yellow
              }
            }
            {
              name: help_menu
              only_buffer_difference: true
              marker: "? "
              type: {
                  layout: description
                  columns: 4
                  col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                  col_padding: 2
                  selection_rows: 4
                  description_rows: 10
              }
              style: {
                  text: green
                  selected_text: green_reverse
                  description_text: yellow
              }
            }
            # Example of extra menus created using a nushell source
            # Use the source field to create a list of records that populates
            # the menu
            {
              name: commands_menu
              only_buffer_difference: false
              marker: "# "
              type: {
                  layout: columnar
                  columns: 4
                  col_width: 20
                  col_padding: 2
              }
              style: {
                  text: green
                  selected_text: green_reverse
                  description_text: yellow
              }
              source: { |buffer, position|
                  $nu.scope.commands
                  | where command =~ $buffer
                  | each { |it| {value: $it.command description: $it.usage} }
              }
            }
            {
              name: vars_menu
              only_buffer_difference: true
              marker: "# "
              type: {
                  layout: list
                  page_size: 10
              }
              style: {
                  text: green
                  selected_text: green_reverse
                  description_text: yellow
              }
              source: { |buffer, position|
                  $nu.scope.vars
                  | where name =~ $buffer
                  | sort-by name
                  | each { |it| {value: $it.name description: $it.type} }
              }
            }
            {
              name: commands_with_description
              only_buffer_difference: true
              marker: "# "
              type: {
                  layout: description
                  columns: 4
                  col_width: 20
                  col_padding: 2
                  selection_rows: 4
                  description_rows: 10
              }
              style: {
                  text: green
                  selected_text: green_reverse
                  description_text: yellow
              }
              source: { |buffer, position|
                  $nu.scope.commands
                  | where command =~ $buffer
                  | each { |it| {value: $it.command description: $it.usage} }
              }
            }
        ]
        keybindings: [
          {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: emacs # Options: emacs vi_normal vi_insert
            event: {
              until: [
                { send: menu name: completion_menu }
                { send: menunext }
              ]
            }
          }
          {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
            event: { send: menuprevious }
          }
          {
            name: history_menu
            modifier: control
            keycode: char_x
            mode: emacs
            event: {
              until: [
                { send: menu name: history_menu }
                { send: menupagenext }
              ]
            }
          }
          {
            name: history_previous
            modifier: control
            keycode: char_z
            mode: emacs
            event: {
              until: [
                { send: menupageprevious }
                { edit: undo }
              ]
            }
          }
          # Keybindings used to trigger the user defined menus
          {
            name: commands_menu
            modifier: control
            keycode: char_t
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: commands_menu }
          }
          {
            name: vars_menu
            modifier: control
            keycode: char_y
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: vars_menu }
          }
          {
            name: commands_with_description
            modifier: control
            keycode: char_u
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: commands_with_description }
          }
        ]
      }
      '';
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
          $directory $character'';
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

        directory = {
          style = "cyan";
          format = "[$read_only]($read_only_style)[$path]($style)";

          read_only = "";
          read_only_style = "red";
          truncation_symbol = "…/";
        };

        nix_shell = {
          style = "bold blue";
          symbol = " ";
          format = " \\([$symbol$state \\($name\\)]($style)\\)";
        };

        hg_branch = {
          style = hg_color;
          symbol = " ";
          format = " [$symbol$branch]($style)";
        };

        git_status = {
          style = git_color;
          format = " [$all_status$ahead_behind]($style)";
        };

        git_branch = {
          style = git_color;
          symbol = " ";
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
        env.TERM = term;
        font.normal.family = font.name;

        window = {
          decorations = "none";
          title = "Terminal Emulator (Alacritty)";
          dynamic_title = false;
        };

        colors = let
          mkColor = id: "0x${theme-colour id}";
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
        window.opacity = 0.97;
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
        neoformat
        nvim-cmp cmp-nvim-lsp
        nvim-dap nvim-dap-ui
        nvim-lspconfig
        nvim-treesitter
        telescope-nvim
        vim-polyglot
        vim-vsnip cmp-vsnip
        which-key-nvim
        # users/enderger/neovim/plugins.editing
        lightspeed-nvim
        nvim-autopairs
        nvim-treesitter-refactor
        supertab
        vim-surround
        # users/enderger/neovim/plugins.utilities
        auto-session
        crates-nvim
        friendly-snippets
        minimap-vim
        nvim-lightbulb
        nvim-treesitter-context
        nvim-ts-rainbow
        # users/enderger/neovim/plugins.integrations
        gitsigns-nvim
        glow-nvim
        neogit
        presence-nvim
        rust-tools-nvim
        toggleterm-nvim
        tup
        # users/enderger/neovim/plugins.ui
        bufferline-nvim
        feline-nvim
        nvim-base16
        nvim-web-devicons nvim-nonicons
      ];

      extraPackages = with pkgs; [
        # users/enderger/neovim/plugins/packages
        # dependencies
        gcc
        git
        ripgrep

        # C++
        ccls lldb

        # Webdev
        deno nodePackages.vscode-html-languageserver-bin nodePackages.vscode-css-languageserver-bin

        # Java
        java-language-server maven

        # Kotlin
        nur.repos.zachcoyle.kotlin-language-server

        # Nim
        nimlsp nim

        # Nix
        rnix-lsp

        # Rust
        (with fenix; combine [
          default.rustfmt-preview default.clippy-preview rust-analyzer
        ])
      ];
      
      langServers = {
        # users/enderger/neovim/plugins/langServers
        zls = {
          enable = true;
          settings = {
            enable_snippets = true;
            warn_style = true;
          };
        };
      };

      luaInit = "init";
      luaModules = {
        # users/enderger/neovim/config
        init = ''
          -- users/enderger/neovim/config/init
          require('editor')
          require('keys')
          require('editing')
          require('extensions')
          require('ui')
          -- require('misc')
        '';
        lib = ''
          -- users/enderger/neovim/config/lib
          local lib = {};

          function lib.autocmd(event, action, filter)
            vim.cmd(string.format("autocmd %s %s %s", event, filter or '*', action))
          end

          function lib.augroup(name, cmds, keepExisting)
            vim.cmd("augroup "..name)

            if not keepExisting then
              vim.cmd("autocmd!")
            end

            for _,cmd in pairs(cmds) do
              lib.autocmd(unpack(cmd))
            end

            vim.cmd("augroup END")
          end

          function lib.map(from, to, mode, opts)
            local defaults = { noremap = true, silent = true }
            vim.api.nvim_set_keymap(mode, from, to, vim.tbl_deep_extend("force", defaults, opts or {}))
          end

          return lib
        '';
        editor = ''
          -- users/enderger/neovim/config/editor
          local opt = vim.opt

          -- asthetic
          opt.background = 'dark'
          opt.cursorline = true
          opt.guifont = '${font.name}' -- interpolated via Nix
          opt.list = true
          opt.number = true
          opt.relativenumber = true
          opt.showmode = false
          opt.signcolumn = 'yes:1'

          -- indentation
          local tabsize = 2
          opt.expandtab = true
          opt.shiftwidth = tabsize
          opt.smartindent = true
          opt.tabstop = tabsize

          -- misc
          opt.confirm = true
          opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
          opt.foldmethod = 'expr'
          opt.hidden = true
          opt.lazyredraw = false
          opt.mouse = 'a'
          opt.spell = false
          opt.title = true
        '';
        keys = ''
          -- users/enderger/neovim/config/keys
          local map = require('lib').map
          local ts = require('telescope.builtin')
          local dapui = require('dapui')
          local dap = require('dap')

          -- leaders
          vim.g.mapleader = ' '
          vim.g.maplocalleader = ','

          -- which-key setup
          local wk = require('which-key')
          wk.setup {}

          -- insert mappings
          map('jk', '<Cmd>stopinsert<CR>', 'i')
          map('<C-Leader>', '<C-o><Leader>', 'i')

          -- window switching
          map('gh', '<C-w>h', 'n')
          map('gj', '<C-w>j', 'n')
          map('gk', '<C-w>k', 'n')
          map('gl', '<C-w>l', 'n')

          -- terminal mappings
          map('<Esc>', '<C-\\><C-n>', 't')

          -- applications
          local application_keys = {
            name = 'apps/',
            d = {
              function() ts.lsp_workspace_diagnostics {} end,
              "diagnostics",
            },
            f = {
              function() ts.file_browser {} end,
              "files",
            },
            g = { 
              function() require('neogit').open { kind = "split" } end, 
              "git",
            },
            m = {
              "<Cmd>MinimapToggle<CR>",
              "minimap",
            },
            s = {
              "<Cmd>ToggleTerm<CR>",
              "shell",
            },
          }
          wk.register(application_keys, { mode = "n", prefix = "<leader>a" })

          -- goto
          local goto_keys = {
            name = 'goto/',
            b = {
              function() ts.buffers {} end,
              "buffer",
            },
            d = {
              function() ts.lsp_definitions {} end,
              "definition",
            },
            f = {
              function() ts.find_files {} end,
              "file",
            },
            ["<S-f>"] = {
              function() ts.find_files { hidden = true } end,
              "file (hidden)",
            },
            i = {
              function() ts.lsp_implementations {} end,
              "implementation",
            },
            r = {
              function() ts.lsp_references {} end,
              "reference",
            },
          }
          wk.register(goto_keys, { mode = "n", prefix = "<leader>g" })

          -- actions
          local action_keys = {
            name = 'actions/',
            c = {
              function() ts.lsp_code_actions {} end,
              "code-actions",
            },
            f = {
              "<Cmd>Neoformat<CR>",
              "format",
            },
            m = {
              "<Cmd>Glow<CR>",
              "markdown-preview",
            },
            r = {
              require("nvim-treesitter-refactor.smart_rename").smart_rename,
              "rename",
            },
            t = {
              "<Cmd>make<CR>",
              "tests/build",
            },
          }
          wk.register(action_keys, { mode = "n", prefix = "<leader>c" })

          -- debugger
          local debug_keys = {
            name = 'debug/',
            t = {
              function() dapui.toggle() end,
              "toggle",
            },
            b = {
              dap.toggle_breakpoint,
              "breakpoint",
            },
            ["<S-b>"] = {
              function()
                local condition = vim.fn.input('Breakpoint condition: ')
                dap.set_breakpoint(condition)
              end,
              "breakpoint/conditional",
            },
            c = {
              dap.continue,
              "continue",
            },
            l = {
              function()
                local message = vim.fn.input('Message: ')
                dap.set_breakpoint(nil, nil, message)
              end,
              "breakpoint/log_point",
            },
            r = {
              function() dap.repl.open() end,
              "repl",
            },
            s = {
              name = "step/",
              i = {
                function() dap.step_into() end,
                "into",
              },
              o = {
                function() dap.step_out() end,
                "out_of",
              },
              p = {
                function() dap.step_over() end,
                "past",
              },
            },
          }
          wk.register(debug_keys, { mode = "n", prefix = "<leader>x" })

          -- help
          local help_keys = {
            name = 'help/',
            t = {
              function() ts.help_tags {} end,
              "help-tags"
            },
            m = {
              function() ts.man_pages {} end,
              "man-pages"
            },
          }
          wk.register(help_keys, { mode = "n", prefix = "<leader>h" })
        '';

        editing = ''
          -- users/enderger/neovim/config/editing
          local lib = require('lib')
          local opt = vim.opt
          local g = vim.g

          -- Completion
          local cmp = require('cmp')
          local cmp_doc_scroll = 4
          cmp.setup {
            snippet = {
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
              end,
            },
            mapping = {
              ['<TAB>'] = cmp.mapping.select_next_item({ cmp.SelectBehavior.Select }),
              ['<S-TAB>'] = cmp.mapping.select_prev_item({ cmp.SelectBehavior.Select }),
              ['<C-j>'] = cmp.mapping.scroll_docs(cmp_doc_scroll),
              ['<C-k>'] = cmp.mapping.scroll_docs(-cmp_doc_scroll),
              ['<CR>'] = cmp.mapping.confirm { select = true },
            },
            sources = {
              { name = 'nvim_lsp' },
              { name = "crates" },
              { name = 'vsnip' },
            },
          }
          opt.completeopt = {'menuone', 'noinsert', 'noselect'}
          opt.shortmess:append('c')

          -- LSP
          local lsp = require('lspconfig')

          --- Capabilities
          local capabilities = require('cmp_nvim_lsp')
            .update_capabilities(vim.lsp.protocol.make_client_capabilities())

          --- Deno
          lsp.denols.setup {
            capabilities = capabilities,
          }

          --- Kotlin
          lsp.kotlin_language_server.setup {
            capabilities = capabilities,
          }

          --- Java
          lsp.java_language_server.setup {
            capabilities = capabilities,
            cmd = {"java-language-server"},
          }

          --- HTML
          lsp.html.setup {
            capabilities = capabilities,
          }

          --- CSS
          lsp.cssls.setup {
            capabilities = capabilities,
          }

          --- C++
          lsp.ccls.setup {
            capabilities = capabilities,
          }

          --- Nim
          lsp.nimls.setup {
            capabilties = capabilities,
          }

          --- Nix
          lsp.rnix.setup {
            capabilities = capabilities,
          }

          --- Rust
          require('rust-tools').setup {
            tools = {},
            server = {
              capabilities = capabilities,
              settings = {
                ['rust-analyzer'] = {
                  -- use Clippy
                  checkOnSave = { command = 'clippy' },
                },
              },
            },
          }

          --- Zig
          lsp.zls.setup {
            capabilities = capabilities,
          }

          -- Debugger
          local dap = require('dap')

          --- UI
          require('dapui').setup {
            sidebar = {
              position = "right",
            },
          }

          --- Adapters
          dap.adapters.lldb = {
            type = 'executable',
            command = '${pkgs.lldb}/bin/lldb-vscode',
            name = 'lldb'
          }

          --- Configurations
          local function getExecutable()
            local prompt = string.format('Executable: %s/', vim.fn.getcwd())
            return vim.fn.input(prompt, 'file')
          end

          --- LLDB
          local lldb_configuration = {
            {
              name = "Launch",
              type = "lldb",
              request = "launch",
              program = getExecutable,
              cwd = '$${workspaceFolder}',
              stopOnEntry = false,
              args = {},
              runInTerminal = false,
            },
          }

          dap.configurations.cpp = lldb_configuration
          dap.configurations.c = lldb_configuration
          dap.configurations.rust = lldb_configuration
          dap.configurations.nim = lldb_configuration

          -- Syntax
          g.markdown_fenced_languages = {'nix', 'lua', 'rust', 'zig'}

          -- HACK: *.s files are detected as R files for backwards compatibility, but I usually use it for GNU Assembler files
          lib.autocmd('BufRead,BufNewFile', 'setfiletype asm', '*.s')

          -- Treesitter
          local ts = require('nvim-treesitter.configs')
          local ts_enabled = { enable = true }
          ts.setup {
            ensure_installed = "all",

            autopairs = ts_enabled,

            highlight = ts_enabled,

            indent = ts_enabled,

            rainbow = {
              enable = true,
              extended_mode = true,
            },

            refactor = {
              highlight_current_scope = ts_enabled,
              highlight_definitions = ts_enabled,
              smart_rename = ts_enabled,
            },
          }


          require('treesitter-context').setup {
            enable = true,
          }

          opt.foldexpr = vim.fn['nvim_treesitter#foldexpr']()

          -- Formatting
          -- WARNING: Tends to destroy data, disabled for now
          --lib.augroup('fmt', {{'BufWritePre', ' undojoin | Neoformat' }})

          -- Lightspeed
          local lightspeed = require('lightspeed')
          lightspeed.setup {}

          -- Autopairs
          local autopairs = require('nvim-autopairs')
          autopairs.setup {
            check_ts = true,
          }

          -- Lightbulb
          lib.autocmd('CursorHold,CursorHoldI', 'lua require(\'nvim-lightbulb\').update_lightbulb()')

          -- Git Signs
          local gitsigns = require('gitsigns')
          gitsigns.setup {}

          -- Crates
          require('crates').setup {}
        '';
        extensions = ''
          -- users/enderger/neovim/config/extensions
          local g = vim.g

          -- Telescope
          local tsc = require('telescope')
          local tsc_themes = require('telescope.themes')
          local tsc_actions = require('telescope.actions')
          tsc.setup {
            defaults = tsc_themes.get_ivy {
              mappings = {
                i = {
                  ['<Tab>'] = tsc_actions.move_selection_next,
                  ['<S-Tab>'] = tsc_actions.move_selection_previous,
                  ['<Esc>'] = tsc_actions.close,
                },
              },

              prompt_prefix = '$ ',
              selection_caret = '> ',
            },
          }

          -- Minimap
          g.minimap_git_colors = true
          g.minimap_highlight_range = true
          g.minimap_width = 10

          -- Git
          local neogit = require('neogit')
          neogit.setup {
            signs = {
              section = { "|", ":" },
              item = { "|", ":" },
              hunk = { "|", ":" },
            },
          }

          -- Terminal
          local toggle_term = require('toggleterm')
          toggle_term.setup {
            hide_numbers = false,
            shading_factor = 1,
            shade_terminals = true,
            open_mapping = "<C-S-t>",
          }

          -- Discord RPC
          local discord = require('presence')
          discord:setup {
            auto_update = true,
            neovim_image_text = "https://man.sr.ht/~hutzdog/dotfiles/users/enderger.md#neovim",
          }
        '';
        ui = ''
          -- users/enderger/neovim/config/ui
          local api = vim.api
          local opt = vim.opt

          -- colours
          local b16 = require('base16-colorscheme')
          local colours = {
            base00 = '#${theme-colour 0}',
            base01 = '#${theme-colour 1}',
            base02 = '#${theme-colour 2}',
            base03 = '#${theme-colour 3}',
            base04 = '#${theme-colour 4}',
            base05 = '#${theme-colour 5}',
            base06 = '#${theme-colour 6}',
            base07 = '#${theme-colour 7}',
            base08 = '#${theme-colour 8}',
            base09 = '#${theme-colour 9}',
            base0A = '#${theme-colour 10}',
            base0B = '#${theme-colour 11}',
            base0C = '#${theme-colour 12}',
            base0D = '#${theme-colour 13}',
            base0E = '#${theme-colour 14}',
            base0F = '#${theme-colour 15}',
          }
          b16.setup(colours)

          -- statusline
          local feline = require('feline')
          local feline_lsp = require('feline.providers.lsp')
          local lsp_severity = vim.diagnostic.severity
          local feline_vi = require('feline.providers.vi_mode')
          local feline_config = {
            components = {
              active = {
                -- left
                {
                  -- mode
                  {
                    provider = 'vi_mode',

                    hl = function()
                      return { 
                        name = feline_vi.get_mode_highlight_name(),
                        fg = feline_vi.get_mode_color(),
                        style = 'bold'
                      }
                    end,

                    right_sep = ' ',
                    left_sep = ' ',
                    icon = "",
                  },

                  -- file info
                  {
                    provider = 'file_info',

                    hl = {
                      fg = 'base05',
                      bg = 'base02',
                      style = 'bold',
                    },

                    left_sep = ' ',
                    right_sep = ' ',
                  },
                  {
                    provider = 'file_type',

                    hl = {
                      fg = 'base05',
                      bg = 'base02',
                      style = 'bold',
                    },

                    left_sep = '(',
                    right_sep = ') ',
                  },
                  {
                    provider = 'position',

                    left_sep = '(',
                    right_sep = ')',
                  },
                }, 

                -- middle
                {
                  -- LSP info
                  {
                    provider = 'diagnostic_errors',
                    enabled = function() return feline_lsp.diagnostics_exist(lsp_severity.ERROR) end,
                    hl = { fg = 'base08' },
                  },
                  {
                    provider = 'diagnostic_warnings',
                    enabled = function() return feline_lsp.diagnostics_exist(lsp_severity.WARN) end,
                    hl = { fg = 'base0A' },
                  },
                  {
                    provider = 'diagnostic_hints',
                    enabled = function() return feline_lsp.diagnostics_exist(lsp_severity.HINT) end,
                    hl = { fg = 'base0C' },
                  },
                  {
                    provider = 'diagnostic_info',
                    enabled = function() return feline_lsp.diagnostics_exist(lsp_severity.INFO) end,
                    hl = { fg = 'base0D' },
                  },
                },  

                -- right
                {
                  -- git info
                  {
                    provider = 'git_branch',

                    hl = { 
                      fg = 'base0C',
                      style = 'bold',
                    },

                    right_sep = ' ',
                  },
                  {
                    provider = 'git_diff_added',

                    hl = { 
                      fg = 'base0B',
                      style = 'bold',
                    },

                    right_sep = ' ',
                  },
                  {
                    provider = 'git_diff_changed',

                    hl = { 
                      fg = 'base09',
                      style = 'bold',
                    },

                    right_sep = ' ',
                  },
                  {
                    provider = 'git_diff_removed',

                    hl = { 
                      fg = 'base08',
                      style = 'bold',
                    },

                    right_sep = ' ',
                  },
                }, 
              },

              inactive = {
                -- left
                { 
                  {
                    provider = 'file_info'
                  }
                },
                {},
                {},
              },
            },
            force_inactive = {
              bufnames = {},
              buftypes = {
                'terminal',
              },
              filetypes = {
                'NeogitStatus',
              },
            },
            mode_colours = {
              NORMAL = 'base0B',
              OP = 'base0B',
              INSERT = 'base08',
              VISUAL = 'base0D',
              BLOCK = 'base0D',
              REPLACE = 'base0E',
              ['V-REPLACE'] = 'base0E',
              ENTER = 'base0C',
              MORE = 'base0C',
              SELECT = 'base0F',
              COMMAND = 'base0B',
              SHELL = 'base0B',
              TERM = 'base0B',
              NONE = 'base0A',
            },
          }

          feline.setup {
            components = feline_config.components,
            force_inactive = feline_config.force_inactive,
            vi_mode_colors = feline_config.mode_colours,
          }

          feline.use_theme(vim.tbl_extend("keep", colours, {
            fg = colours.base04,
            bg = colours.base01 
          }))

          -- bufferline
          local bufferline = require('bufferline')

          bufferline.setup {
            options = {
              numbers = function(it)
                return it.ordinal
              end,
              show_close_icon = false,
              show_tab_indicators = false,
              buffer_close_icon = 'x',
              modified_icon = '+',
              diagnostics = "nvim_lsp",
              separator_style = 'thin',
              always_show_bufferline = true,
            },
          }
        '';
        /* Will uncomment when needed
        misc = ''
  <<<users/enderger/neovim/config/misc>>>
        '';
        */
      };
    };
    # users/enderger/emacs
    programs.emacs = let
      emacs = pkgs.emacsUnstable;
      emacs' = (pkgs.emacsPackagesFor emacs).emacsWithPackages (epkgs:
        with epkgs; let p = pkgs; in [
          # users/enderger/emacs/packages
          # Editing
          company company-quickhelp
          eglot
          format-all p.nodePackages.prettier

          # HACK: tree-sitter support in nixpkgs/emacs-overlay is broken
          p.emacs28Packages.tree-sitter
          p.emacs28Packages.tree-sitter-langs

          # Keys
          ace-window
          meow
          vterm vterm-toggle
          which-key

          # Dependencies
          p.python3 p.git

          # Languages
          ## C(++)
          p.ccls

          ## Clojure
          clojure-mode cider
          p.clojure p.clojure-lsp p.leiningen

          ## Javascript
          p.deno

          ## Lua
          p.sumneko-lua-language-server lua-mode

          ## Markdown
          markdown-mode poly-markdown poly-R ess

          ## Nim
          p.nim p.nimlsp nim-mode

          ## Nix
          nix-mode

          ## Ocaml
          caml p.ocaml
          dune p.dune_2
          merlin merlin-company p.ocamlPackages.merlin
          tuareg
          utop p.ocamlPackages.utop

          ## Raku
          flymake-rakudo p.rakudo
          raku-mode

          ## Rust
          (with p.fenix; combine [
            default.rustfmt-preview default.clippy-preview rust-analyzer
            p.gcc
          ])
          rust-mode

          ## Shell
          flymake-shellcheck p.shellcheck

          ## Zig
          p.zig p.zls zig-mode

          # Integrations
          direnv
          elcord
          magit git-gutter
          restclient company-restclient
          treemacs

          # Theming
          all-the-icons
          centaur-tabs
          dashboard
          doom-themes
          hl-todo
          mini-modeline
        ]);
      in {
      enable = true;
      package = emacs';
      extraConfig = ''
        ; users/enderger/emacs/functionality

        ; Completions
        ;; Company
        (require 'company)
        (require 'company-quickhelp)
        (add-hook 'after-init-hook 'global-company-mode)
        (add-hook 'after-init-hook 'company-quickhelp-mode)

        (setq company-idle-delay 0)
        (setq company-minimum-prefix-length 1)
        (setq company-selection-wrap-around t)

        (with-eval-after-load 'company
          (define-key company-active-map
            (kbd "<tab>")
            #'company-complete-common-or-cycle)
          (define-key company-active-map
            (kbd "<backtab>")
            (lambda () (interactive)
              (company-complete-common-or-cycle -1))))

        ;; Direnv
        (require 'direnv)
        (direnv-mode)

        ;; LSP
        (require 'eglot)
        (setq eglot-autoreconnect t)

        ;; Flymake
        (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)

        ; Backup files
        (setq backup-directory-alist `(("." . "~/.cache/emacs/backups")))

        ; Indentation
        (setq-default indent-tabs-mode nil)
        (electric-indent-mode nil)

        ; Formatting
        (require 'format-all)
        (defun register-formatter (hook)
          (add-hook hook 'format-all-ensure-formatter)
          (add-hook hook 'format-all-mode))
        ; users/enderger/emacs/interface
        ;; Theme
        (require 'doom-themes)
        (load-theme 'doom-nord t)

        ;; Numbers
        (global-display-line-numbers-mode)
        (setq display-line-numbers-type 'relative)
        (set-face-attribute 'line-number-current-line nil
          :weight 'bold
          :foreground "white")

        ;; Cursorline
        (global-hl-line-mode)

        ;; Modeline
        (require 'mini-modeline)
        (setq mini-modeline-enhance-visual t)
        (setq mini-modeline-display-gui-line nil)
        (mini-modeline-mode t)

        ;; Tabline
        (require 'centaur-tabs)
        (setq centaur-tabs-height 16)
        (setq centaur-tabs-set-bar 'left)
        (centaur-tabs-mode t)

        ;; GUI Elements
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (toggle-scroll-bar -1)
        (whitespace-mode)

        ;; Todos
        (require 'hl-todo)
        (setq hl-todo-keyword-faces
        	  '(("TODO" . (face-attribute 'org-todo :foreground))
        		("FIXME" . (face-attribute 'error :foreground))
        		("HACK" . (face-attribute 'warning :foreground))))
        (add-hook 'prog-mode-hook 'hl-todo-mode)

        ;; Start Screen
        (require 'dashboard)
        (setq dashboard-startup-banner 'logo)
        (setq dashboard-show-shortcuts t)
        (dashboard-setup-startup-hook)

        ;; Syntax
        (require 'tree-sitter)
        (require 'tree-sitter-langs)
        (add-hook 'after-init-hook 'global-tree-sitter-mode)

        ;; Ido
        (require 'ido)
        (setq ido-enable-flex-matching t)
        (setq ido-everywhere t)
        (ido-mode t)

        ;; File tree
        (require 'treemacs)
        (setq doom-themes-treemacs-theme "doom-nord")
        (doom-themes-treemacs-config)

        ;; Git integration
        (require 'magit)
        (require 'git-gutter)
        (global-git-gutter-mode +1)

        ;; REST Client
        (require 'restclient)
        (defun restclient-buffer ()
          (interactive)
          (switch-to-buffer-other-frame "*rest-client*")
          (restclient-mode))
        (require 'company-restclient)
        (add-to-list 'company-backends 'company-restclient)

        ;; Discord Presence
        (require 'elcord)
        (add-hook 'after-init-hook 'elcord-mode)

        ;; Highlight Whitespace
        (progn
          (setq whitespace-style
                '(face spaces tabs newline space-mark tab-mark newline-mark trailing))
          (setq whitespace-display-mappings
                '((space-mark ? [?·] [? ])
                  (newline-mark ?\n [?⏎ ?\n])
                  (tab-mark ?\t [?↦ ?\t]))))
        (global-whitespace-mode)
        ; users/enderger/emacs/keys
        ;; Which-key
        (require 'which-key)
        (which-key-mode)

        ;; Ace Window
        (require 'ace-window)
        (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

        ;; Shell Pop
        (require 'vterm)
        (require 'vterm-toggle)

        ;; Auto pairs
        (electric-pair-mode t)

        ;; Meow
        (require 'meow)

        ;;; Use meow QWERTY keys
        (defun meow-setup ()
          (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
          (meow-motion-overwrite-define-key
           '("j" . meow-next)
           '("k" . meow-prev)
           '("<escape>" . ignore)
           '(":" . execute-extended-command))
          (meow-leader-define-key
           ;; SPC j/k will run the original command in MOTION state.
           '("j" . "H-j")
           '("k" . "H-k")
           ;; Use SPC (0-9) for digit arguments.
           '("1" . meow-digit-argument)
           '("2" . meow-digit-argument)
           '("3" . meow-digit-argument)
           '("4" . meow-digit-argument)
           '("5" . meow-digit-argument)
           '("6" . meow-digit-argument)
           '("7" . meow-digit-argument)
           '("8" . meow-digit-argument)
           '("9" . meow-digit-argument)
           '("0" . meow-digit-argument)
           '("/" . meow-keypad-describe-key)
           '("?" . meow-cheatsheet)
           '("f" . treemacs)
           '("v" . magit)
           '("r" . eval-expression)
           '("n" . centaur-tabs-forward)
           '("p" . centaur-tabs-backward)
           '("d" . kill-whole-line)
           '("q" . kill-buffer)
           '("e" . find-file)
           '("s" . ace-window)
           '("w" . save-buffer)
           '("t" . vterm-toggle)
           '("l" . restclient-buffer))
          (meow-normal-define-key
           '("0" . meow-expand-0)
           '("9" . meow-expand-9)
           '("8" . meow-expand-8)
           '("7" . meow-expand-7)
           '("6" . meow-expand-6)
           '("5" . meow-expand-5)
           '("4" . meow-expand-4)
           '("3" . meow-expand-3)
           '("2" . meow-expand-2)
           '("1" . meow-expand-1)
           '("-" . negative-argument)
           '(";" . meow-reverse)
           '("," . meow-inner-of-thing)
           '("." . meow-bounds-of-thing)
           '("[" . meow-beginning-of-thing)
           '("]" . meow-end-of-thing)
           '("a" . meow-append)
           '("A" . meow-open-below)
           '("b" . meow-back-word)
           '("B" . meow-back-symbol)
           '("c" . meow-change)
           '("d" . meow-delete)
           '("D" . meow-backward-delete)
           '("e" . meow-next-word)
           '("E" . meow-next-symbol)
           '("f" . meow-find)
           '("g" . meow-cancel-selection)
           '("G" . meow-grab)
           '("h" . meow-left)
           '("H" . meow-left-expand)
           '("i" . meow-insert)
           '("I" . meow-open-above)
           '("j" . meow-next)
           '("J" . meow-next-expand)
           '("k" . meow-prev)
           '("K" . meow-prev-expand)
           '("l" . meow-right)
           '("L" . meow-right-expand)
           '("m" . meow-join)
           '("n" . meow-search)
           '("o" . meow-block)
           '("O" . meow-to-block)
           '("p" . meow-yank)
           '("q" . meow-quit)
           '("Q" . meow-goto-line)
           '("r" . meow-replace)
           '("R" . meow-swap-grab)
           '("s" . meow-kill)
           '("t" . meow-till)
           '("u" . meow-undo)
           '("U" . meow-undo-in-selection)
           '("v" . meow-visit)
           '("w" . meow-mark-word)
           '("W" . meow-mark-symbol)
           '("x" . meow-line)
           '("X" . meow-goto-line)
           '("y" . meow-save)
           '("Y" . meow-sync-grab)
           '("z" . meow-pop-selection)
           '("'" . repeat)
           '("<escape>" . ignore)
           '(":" . execute-extended-command)
           '("/" . (lambda () (interactive)
        			 (isearch-forward-regexp)))
           '("?" . (lambda () (interactive)
        			 (isearch-backward-regexp)))))

        (meow-setup)
        (meow-global-mode t)
        ; users/enderger/emacs/languages
        ;; C(++)
        (add-hook 'c-mode-hook #'eglot-ensure)
        (add-hook 'c++-mode-hook #'eglot-ensure)


        ;; Clojure
        (require 'clojure-mode)
        (require 'cider)

        (add-hook 'clojure-mode-hook #'eglot-ensure)
        (add-hook 'clojurescript-mode-hook #'eglot-ensure)
        (add-hook 'clojurec-mode-hook #'eglot-ensure)

        ;; Elisp
        (register-formatter 'emacs-lisp-mode-hook)

        ;; Lua
        (require 'lua-mode)
        (add-to-list 'eglot-server-programs '(lua-mode . ("lua-language-server")))
        (add-hook 'lua-mode-hook #'eglot-ensure)

        ;; Nim
        (require 'nim-mode)
        (add-to-list 'eglot-server-programs '(nim-mode . ("nimlsp")))
        (add-hook 'nim-mode-hook #'eglot-ensure)

        ;; Nix
        (require 'nix-mode)
        (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

        ;; Ocaml
        (require 'tuareg)
        (require 'caml)
        (require 'merlin)
        (require 'merlin-company)

        (add-hook 'tuareg-mode-hook 'merlin-mode t)
        (add-hook 'caml-mode-hook 'merlin-mode t)
        (add-to-list 'company-backends 'merlin-company-backend)
        (add-hook 'tuareg-mode-hook 'utop-minor-mode)

        ;; Rakudo
        (require 'raku-mode)
        (require 'flymake-rakudo)
        (add-hook 'raku-mode-hook #'flymake-mode)
        (add-hook 'raku-mode-hook #'flymake-rakudo-setup)

        ;; Rust
        (require 'rust-mode)
        (add-hook 'rust-mode-hook #'eglot-ensure)
        (add-hook 'rust-mode-hook (lambda () (prettify-symbols-mode)))
        (register-formatter 'rust-mode-hook)

        ;; Shell Script
        (require 'flymake-shellcheck)
        (add-hook 'shell-shell-mode-hook 'flymake-mode t)
        (add-hook 'shell-shell-mode-hook 'flymake-shellcheck-load)

        ;; Zig
        (require 'zig-mode)
        (add-hook 'zig-mode-hook #'eglot-ensure)

        ;; Markdown
        (require 'markdown-mode)
        (require 'poly-R)
        (require 'poly-markdown)
      '';
      };

    services.emacs = {
        enable = true;
        defaultEditor = true;
        client.enable = true;
    };
    # users/enderger/git
    programs.git = {
      enable = true;
      userEmail = "endergeryt@gmail.com";
      userName = "Enderger";
    };
    # users/enderger/direnv
    programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
    };

    # GUI Setup
    # users/enderger/awesome
    xsession.windowManager.awesome = {
      luaConfig = {
        rc = ''
          -- users/enderger/awesome/rc
          local naughty = require('naughty')

          -- error handling
          naughty.connect_signal("request::display_error", function(message, startup)
            local error_type = startup and "Startup" or "Runtime"

            -- show notification
            naughty.notification {
              urgency = "critical",
              title = error_type.." error!",
              message = message,
            }

            -- write to file
            local fd = io.open(os.getenv("HOME")..'/awesome-err.log', 'w')
            fd:write(error_type.." error:\n")
            fd:write(message)
            fd:close()
          end)

          require('theme').setup()
          require('menubar').terminal = '${term}'

          require('keys').setup()
          require('rules').setup()
          require('screens').setup()
          require('init').setup()
        '';
        lib = ''
          -- users/enderger/awesome/lib
          local M = {}

          function M.fix_args(f, before, use_inputs, after)
            return function(...)
              local args = use_inputs and table.pack(...) or {}
              return f(table.unpack(before or {}), table.unpack(args), table.unpack(after or {}))
            end
          end

          return M
        '';
        widgets = ''
          -- users/enderger/awesome/widgets
          local M = {
            listeners = {},
            components = {},
            widgets = {},
            boxes = {},
          }
          package.loaded[...] = M

          local awful = require('awful')
          local beautiful = require('beautiful')
          local keys = require('keys')
          local layout = require('wibox.layout')
          local lib = require('lib')
          local wibox = require('wibox')

          -- listeners
          function M.listeners.hover(w)
            local function hover_signal(enter)
              return function() 
                w:emit_signal("mouse::toggle", enter) 
              end
            end

            w:connect_signal("mouse::enter", hover_signal(true))
            w:connect_signal("mouse::leave", hover_signal(false))
            w:emit_signal("mouse::toggle", false)
            return w
          end

          -- containers

          -- layouts

          -- components
          function M.components.button(text, trigger)
            -- variables
            local colours = {
              bg = beautiful.bg_normal,
              hover = beautiful.bg_focus,
              fg = beautiful.fg_normal,
              border = beautiful.border_color_normal,
            }

            -- widgets
            local textbox = wibox.widget {
              markup = text,
              align = "center",
              valign = "center",
              widget = wibox.widget.textbox,
            }
            local widget = wibox.widget {
              textbox,

              border_width = 1,
              border_color = colours.border,
              fg = colours.fg,
              bg = colours.bg,

              widget = wibox.container.background,
            }

            -- hovering
            widget:connect_signal("mouse::toggle", function(self, enter)
              local bg = colours.bg
              if enter then bg = colours.hover end
              self.bg = bg
            end)
            M.listeners.hover(widget)

            -- buttons
            widget:add_button(awful.button({}, 1, trigger))

            return widget
          end

          function M.components.title(text)
            local widget = wibox.widget {
              markup = '<big>'..text..'</big>',

              align = 'center',
              valign = 'center',

              widget = wibox.widget.textbox,
            }
            
            return widget
          end

          -- widgets
          function M.widgets.logout_menu()
            local cs = M.components

            -- variables  
            local colours = {
              bg = beautiful.bg_normal,
              border = beautiful.border_color_normal,
            }

            -- widgets
            local button_panel = wibox.widget {
              cs.button('Reload', awesome.restart),
              cs.button('Logout', awesome.quit),
              cs.button('Lock', lib.fix_args(awful.spawn, { '${lock}' })),
              cs.button('Sleep', lib.fix_args(awful.spawn, { 'systemctl suspend' })),
              cs.button('Shutdown', lib.fix_args(awful.spawn, { 'systemctl poweroff' })),
              cs.button('Reboot', lib.fix_args(awful.spawn, { 'systemctl reboot' })),

              layout = wibox.layout.fixed.vertical,
            }
            local widget = wibox.widget {
              {
                cs.title('Exit Awesome'),
                button_panel,

                layout = wibox.layout.fixed.vertical,
              },

              bg = colours.bg,
              border_width = 1,
              border_color = colours.border,
              widget = wibox.container.background,
            }

            return widget
          end

          function M.widgets.promptbox(s)
            local pb = awful.widget.prompt

            -- widgets
            local widget = wibox.widget {
              prompt = '$ ',
              widget = pb,
            }

            return widget
          end

          function M.widgets.taglist(s)
            local tl = awful.widget.taglist

            -- args
            local args = {
              screen = s,
              filter = tl.filter.all,
            }
            args.buttons = {
              awful.button({ }, 1, function(t)
                t:view_only() 
              end),
              awful.button({ keys.modifier }, 1, function(t)
                  if client.focus then
                    client.focus:move_to_tag(t)
                  end
                end),
              awful.button({ }, 4, function(t) 
                awful.tag.viewprev(t.screen)
              end),
              awful.button({ }, 5, function(t)
                awful.tag.viewnext(t.screen) 
              end),
            }

            -- widgets
            local widget = tl(args)

            return widget
          end

          function M.widgets.tasklist(s)
            local tl = awful.widget.tasklist

            -- args
            local args = {
              screen = s,
              filter = tl.filter.currenttags,
            }
            args.layout = {
              spacing = 1,
              layout = wibox.layout.fixed.horizontal,
            }
            args.widget_template = {
              {
                wibox.widget.base.make_widget(),
                forced_height = 2,
                id = 'background_role',
                widget = wibox.container.background,
              },
              {
                awful.widget.clienticon,
                margins = 2,
                widget = wibox.container.margin,
              },
              nil,
              forced_width = 20,
              layout = wibox.layout.align.vertical,
            }
            args.buttons = {
              awful.button({ }, 1, function(c)
                c:activate {
                  context = "tasklist",
                  action = "toggle_minimization",
                }
              end),
              awful.button({ }, 3, function()
                awful.menu.client_list {
                  theme = {
                    width = 250,
                  },
                } 
              end),
              awful.button({ }, 4, function()
                awful.client.focus.byidx(-1)
              end),
              awful.button({ }, 5, function()
                awful.client.focus.byidx(1) 
              end),
            }

            -- widgets
            local widget = tl(args)

            return widget
          end

          function M.widgets.textclock()
            -- widgets
            local widget = wibox.widget {
              format = '%a %b %d %H:%M ',
              widget = wibox.widget.textclock,
            }

            return widget
          end

          -- boxes
          function M.boxes.logout(s)
            local ws = M.widgets

            -- setup
            local box = wibox {
              screen = s,
              width = 100,
              height = 200,
              ontop = true,
            }

            -- placement
            awful.placement.centered(box)

            -- layout
            box:setup {
              ws.logout_menu(),
              layout = wibox.layout.fixed.vertical,
            }

            -- buttons
            local function close()
              box.visible = false
            end
            box.buttons = {
              awful.button({}, 1, close),
              awful.button({}, 3, close),
            }

            return box
          end

          function M.boxes.titlebar(c)
            local tb = awful.titlebar

            -- setup
            local box = tb(c, {
              size = 15,
              bg_normal = beautiful.bg_focus,
            })
            
            -- widgets
            local left = wibox.widget {
              tb.widget.iconwidget(c),

              layout = wibox.layout.fixed.horizontal,
            }
            local centre = wibox.widget {
              {
                align = "center",
                widget = tb.widget.titlewidget(c),
              },

              layout = wibox.layout.flex.horizontal,
            }
            local right = wibox.widget { 
              tb.widget.floatingbutton(c),
              tb.widget.maximizedbutton(c),
              tb.widget.closebutton(c),

              layout = wibox.layout.fixed.horizontal,
            }

            -- buttons
            local function tb_button(action)
              return c:activate { context = "titlebar", action = action }
            end
            local buttons = {
              awful.button({ }, 1, lib.fix_args(tb_button, { "mouse_move" })),
              awful.button({ }, 3, lib.fix_args(tb_button, { "mouse_resize" })),
            }
            left.buttons = buttons
            centre.buttons = buttons

            -- layout
            box:setup {
              left, centre, right,

              layout = wibox.layout.align.horizontal,
            }

            return box
          end

          function M.boxes.wibar(s)
            local ws = M.widgets

            -- variables
            local spacing = 1

            -- container
            local box = awful.wibar {
              position = "top",
              screen = s,
            }

            -- widgets
            local mainmenu = awful.widget.button {
              image = beautiful.awesome_icon,
              buttons = {
                awful.button({}, 1, nil, lib.fix_args(require('menubar').show)),
              },
            }
            local spacer = wibox.widget {
              color = beautiful.fg_minimize,
              widget = wibox.widget.separator,
            }
            local systray = wibox.widget.systray()
            local textclock = ws.textclock()

            box:setup {
              {
                mainmenu,
                s.my.widgets.taglist,
                s.my.widgets.promptbox,
                s.my.widgets.tasklist,

                spacing = spacing,
                spacing_widget = spacer,
                layout = wibox.layout.fixed.horizontal,
              },
              nil,
              {
                textclock,
                systray,

                spacing = spacing,
                spacing_widget = spacer,
                layout = wibox.layout.fixed.horizontal, 
              },
              layout = wibox.layout.align.horizontal,
            }
            return box
          end

          -- setup functions
          function M.setup_client(c)
            local bs = M.boxes
            
            c.my = {}
            c.my.boxes = {
              titlebar = M.boxes.titlebar(c),
            }

            return c
          end

          function M.setup_screen(s)
            -- widgets
            local ws = M.widgets
            local bs = M.boxes

            s.my = {}
            s.my.widgets = {
              promptbox = ws.promptbox(s),
              taglist = ws.taglist(s),
              tasklist = ws.tasklist(s),
            }
            s.my.boxes = {
              logout = bs.logout(s),
              wibar = bs.wibar(s), 
            }

            return s
          end

          return M
        '';

        init = ''
          -- users/enderger/awesome/init
          local M = {}
          local spawn = require('awful.spawn').once

          function M.setup()
            spawn('systemctl --user start graphical-session-pre')
            spawn('feh --bg-scale '..(require('beautiful').wallpaper))
            spawn('lxqt-policykit-agent')
            spawn('blueman-applet')
            spawn('nheko')

            spawn('discord', {
              tag = screen[2].tags[5]
            })
          end

          return M
        '';
        keys = ''
          -- users/enderger/awesome/keys
          local M = {}

          local awful = require('awful')
          local lib = require('lib')
          local widgets = require('widgets')

          -- modifiers
          M.leader = 'Mod4'
          M.modifier = 'Shift'
          M.alternate = 'Control'

          -- groups
          M.keygroups = require('gears.table').join(awful.key.keygroups, {
            vimkeys = {
              {'h', 'left'},
              {'j', 'down'},
              {'k', 'up'},
              {'l', 'right'},
            },

            vimcycle = {
              {'n', 1},
              {'p', -1},
            },
          })

          -- tables
          M.groups = {
            wm = 'window management',
            launchers = 'launchers',
            client = 'client',
          }

          function M.global_keys(awful)
            return {
              -- window management
              awful.key {
                modifiers = { M.leader, M.alternate },
                key = 'q',
                
                on_press = function()
                  awful.screen.focused().my.boxes.logout.visible = true
                end, 

                description = 'Exit Awesome',
                group = M.groups.wm,
              },

              awful.key {
                modifiers = { M.leader, M.alternate },
                key = 'm',

                on_press = function()
                  local c = awful.client.restore()

                  if c then
                    c:activate { raise = true, context = 'key.unminimize' }
                  end
                end,

                description = 'Unminimize',
                group = M.groups.wm,
              },

              --- clients
              awful.key {
                modifiers = { M.leader },
                keygroup = 'vimkeys',
                
                on_press = awful.client.focus.global_bydirection,

                description = 'Focus client',
                group = M.groups.wm,
              },

              --- screens
              awful.key {
                modifiers = { M.leader, M.modifier },
                keygroup = 'vimcycle',
                
                on_press = awful.screen.focus_relative,

                description = 'Focus screen',
                group = M.groups.wm,
              },

              --- tags
              awful.key {
                modifiers = { M.leader },
                keygroup = 'vimcycle',
                
                on_press = awful.tag.viewidx,

                description = 'Cycle tags',
                group = M.groups.wm,
              },

              awful.key {
                modifiers = { M.leader },
                keygroup = 'numrow',

                on_press = function (idx)
                  local tag = awful.screen.focused().tags[idx]

                  if tag then
                    tag:view_only()
                  end
                end,

                description = 'Focus tag',
                group = M.groups.wm,
              },

              --- layout
              awful.key {
                modifiers = { M.leader },
                key = 'Tab',

                on_press = function()
                  local s = awful.screen.focused {}
                  awful.layout.inc(1, s)
                end,

                description = 'Next layout',
                group = M.groups.wm,
              },

              awful.key {
                modifiers = { M.leader, M.modifier },
                key = 'Tab',

                on_press = function()
                  local s = awful.screen.focused {}
                  awful.layout.inc(-1, s)
                end,

                description = 'Previous layout',
                group = M.groups.wm,
              },

              -- app launchers
              awful.key {
                modifiers = { M.leader },
                key = 'r',

                on_press = lib.fix_args(require('menubar').show),

                description = 'Application menu',
                group = M.groups.launchers,
              },

              awful.key {
                modifiers = { M.leader },
                key = 'Return',

                on_press = lib.fix_args(awful.spawn, { '${term}' }),

                description = 'Launch terminal',
                group = M.groups.launchers,
              },

              awful.key {
                modifiers = { M.leader },
                key = 'b',

                on_press = lib.fix_args(awful.spawn, { '${browser}' }),

                description = 'Launch web browser',
                group = M.groups.launchers,
              },

              awful.key {
                modifiers = { M.leader },
                key = 'e',

                on_press = lib.fix_args(awful.spawn, { '${editor}' }),

                description = 'Launch text editor',
                group = M.groups.launchers,
              },
            }
          end

          function M.client_keys(awful)
            return {
              awful.key {
                modifiers = { M.leader, M.modifier },
                key = 'c',

                on_press = function(c) 
                  c:kill()
                end,

                description = 'Close program',
                group = M.groups.client,
              },

              -- properties
              awful.key {
                modifiers = { M.leader },
                key = 'f',

                on_press = function(c)
                  c.maximized = not c.maximized
                  c:raise()
                end,

                description = 'Toggle maximized',
                group = M.groups.client,
              },

              awful.key {
                modifiers = { M.leader, M.modifier },
                key = 'f',

                on_press = function(c)
                  c.floating = not c.floating
                end,

                description = 'Toggle floating',
                group = M.groups.client,
              },

              -- movement
              awful.key {
                modifiers = { M.leader },
                key = 'm',

                on_press = awful.client.setmaster,

                description = 'Set master',
                group = M.groups.client,
              },

              awful.key {
                modifiers = { M.leader, M.modifier },
                key = 'm',

                on_press = awful.client.setslave,

                description = 'Set slave',
                group = M.groups.client,
              },

              awful.key {
                modifiers = { M.leader, M.modifier },
                keygroup = 'vimkeys',

                on_press = function(dir, c)
                  awful.client.swap.bydirection(dir, c)
                end,

                description = 'Move client',
                group = M.groups.client,
              },

              awful.key {
                modifiers = { M.leader, M.modifier },
                keygroup = 'numrow',

                on_press = function (idx, c)        
                  local t = c.screen.tags[idx]
                  if t then
                    c:move_to_tag(t)
                  end
                end,

                description = 'Move to tag',
                group = M.groups.client,
              },

              awful.key {
                modifiers = { M.leader, M.alternate },
                keygroup = 'vimcycle',
                
                on_press = function(dir, c)
                  local s = c.screen
                  c:move_to_screen(s.index + dir)
                  awful.screen.focus(s)
                end,

                description = 'Move to screen',
                group = M.groups.client,
              },
            }
          end

          function M.client_mouse(awful)
            return {
              awful.button({ }, 1, function(c)
                c:activate { context = "mouseclick" }
              end),
              awful.button({ M.leader }, 1, awful.mouse.client.move),
              awful.button({ M.leader }, 3, awful.mouse.client.move),
            }
          end

          function M.setup()
            awful.key.keygroups = M.keygroups
            
            local kb = awful.keyboard 
            kb.append_global_keybindings(M.global_keys(awful))
            kb.append_client_keybindings(M.client_keys(awful))

            local ms = awful.mouse
            ms.append_client_mousebindings(M.client_mouse(awful))
          end

          return M
        '';
        rules = ''
          -- users/enderger/awesome/rules
          local M = {}

          local awful = require('awful')
          local widgets = require('widgets')

          -- declarative
          M.rules = {
            {
              id = 'floating',
              rule_any = {
                class = {'Steam'},
                type = {'dialog', 'utility', 'splash'}
              },
              properties = { 
                floating = true,
              },
            },
            {
              id = 'focus',
              rule = {},
              properties = {
                focus = awful.client.focus.filter,
                raise = true,
                screen = awful.screen.preferred,
              },
            },
            {
              id = 'titlebars',
              rule_any = {
                type = {'normal', 'dialog'},
              },
              properties = { 
                titlebars_enabled = true 
              },
            },
            {
              id = 'discord',
              rule = {
                class = {"discord"},
                properties = {
                  tag = screen[2].tags[5]
                }
              }

            }
          }

          -- signals
          function M.on_client_unmanage(c)
            if client.focused then return end
            local new_c = awful.client.getmaster(c.screen)

            if new_c then
              new_c:activate { context = "inherited" }
            end
          end

          function M.on_tag_switch(t)
            if not t then return end

            local c = awful.client.getmaster(t.screen)
            if c then
              c:activate { context = "switchtag" }
            end
          end

          function M.on_titlebar_request(c)
            widgets.setup_client(c)
          end

          function M.setup()
            require('ruled.client').append_rules(M.rules)

            -- client rules
            client.connect_signal("request::unmanage", M.on_client_unmanage)
            client.connect_signal("request::titlebars", M.on_titlebar_request)

            -- tag rules
            awful.tag.attached_connect_signal(nil, "property::selected", M.on_tag_switch)
          end

          return M
        '';
        screens = ''
          -- users/enderger/awesome/screens
          local M = {}

          local awful = require('awful')
          local widgets = require('widgets')

          -- layout
          local l = awful.layout.suit
          M.layouts = { 
            l.tile.left,
            l.tile.bottom,
            l.max,
            l.fair,
            l.floating,
          }

          -- tags
          M.tags = { 'α', 'β', 'θ', 'λ', 'μ', 'ω' }
          local function set_tags(s)
            awful.tag(M.tags, s, awful.layout.layouts[1])
          end

          function M.setup()
            awful.layout.append_default_layouts(M.layouts)
            
            awful.screen.connect_for_each_screen(function(s)
              set_tags(s)
              widgets.setup_screen(s)
            end)
          end

          return M
        '';
        theme = ''
          -- users/enderger/awesome/theme
          local M = {}

          local beautiful = require('beautiful')
          local assets = require('beautiful.theme_assets')
          local xresources = beautiful.xresources

          -- helpers
          local function parse_colour(hex)
            return '#'..hex
          end

          local function get_default(path)
            local theme_dir = require("gears.filesystem").get_themes_dir()
            return theme_dir..'default/'..path
          end

          local function collection(path, ext)
            return function(name)
              return get_default(path..'/'..name..ext)
            end
          end

          local titlebar_icon = collection('titlebar', '.png')
          local layout_icon = collection('layouts', 'w.png')

          -- variables
          M.font = '${font.name} {builtins.toString font.size}'
          M.tl_square_size = xresources.apply_dpi(4)
          M.menu_height = xresources.apply_dpi(15)

          -- colours
          M.colours = {
            base00 = parse_colour('${theme-colour 0}'),
            base01 = parse_colour('${theme-colour 1}'),
            base02 = parse_colour('${theme-colour 2}'),
            base03 = parse_colour('${theme-colour 3}'),
            base04 = parse_colour('${theme-colour 4}'),
            base05 = parse_colour('${theme-colour 5}'),
            base06 = parse_colour('${theme-colour 6}'),
            base07 = parse_colour('${theme-colour 7}'),
            base08 = parse_colour('${theme-colour 8}'),
            base09 = parse_colour('${theme-colour 9}'),
            base0A = parse_colour('${theme-colour 10}'),
            base0B = parse_colour('${theme-colour 11}'),
            base0C = parse_colour('${theme-colour 12}'),
            base0D = parse_colour('${theme-colour 13}'),
            base0E = parse_colour('${theme-colour 14}'),
            base0F = parse_colour('${theme-colour 15}'),
          }

          function M.setup()
            local c = M.colours

            beautiful.init {
              font = M.font,
              wallpaper = '~/wallpapers/wallpaper.jpg',
              
              -- backgrounds
              bg_normal = c.base00,
              bg_focus = c.base02,
              bg_urgent = c.base00,
              bg_minimize = c.base00,
              bg_systray = c.base02,
              prompt_bg = c.base02,
              
              -- foregrounds
              fg_normal = c.base05,
              fg_focus = c.base05,
              fg_urgent = c.base0A,
              fg_minimize = c.base03,

              -- borders
              useless_gap = xresources.apply_dpi(2),
              border_width = xresources.apply_dpi(1),
              border_color_normal = c.base03,
              border_color_active = c.base04,
              border_color_marked = c.base05,

              -- taglist
              taglist_squares_sel = assets.taglist_squares_sel(
                M.tl_square_size, c.base05
              ),
              taglist_squares_unsel = assets.taglist_squares_unsel(
                M.tl_square_size, c.base05
              ),

              -- menu
              menu_submenu_icon = get_default('submenu.png'),
              menu_height = M.menu_height,
              menu_width = xresources.apply_dpi(100),

              -- titlebars
              titlebar_close_button_normal = titlebar_icon('close_normal'),
              titlebar_close_button_focus = titlebar_icon('close_focus'),

              titlebar_minimize_button_normal = titlebar_icon('minimize_normal'),
              titlebar_minimize_button_focus = titlebar_icon('minimize_focus'),

              titlebar_ontop_button_normal_inactive = titlebar_icon('ontop_normal_inactive'),
              titlebar_ontop_button_focus_inactive = titlebar_icon('ontop_focus_inactive'),
              titlebar_ontop_button_normal_active = titlebar_icon('ontop_normal_active'),
              titlebar_ontop_button_focus_active = titlebar_icon('ontop_focus_active'),

              titlebar_sticky_button_normal_inactive = titlebar_icon('sticky_normal_inactive'),
              titlebar_sticky_button_focus_inactive = titlebar_icon('sticky_focus_inactive'),
              titlebar_sticky_button_normal_active = titlebar_icon('sticky_normal_active'),
              titlebar_sticky_button_focus_active = titlebar_icon('sticky_focus_active'),

              titlebar_floating_button_normal_inactive = titlebar_icon('floating_normal_inactive'),
              titlebar_floating_button_focus_inactive = titlebar_icon('floating_focus_inactive'),
              titlebar_floating_button_normal_active = titlebar_icon('floating_normal_active'),
              titlebar_floating_button_focus_active = titlebar_icon('floating_focus_active'),

              titlebar_maximized_button_normal_inactive = titlebar_icon('maximized_normal_inactive'),
              titlebar_maximized_button_focus_inactive = titlebar_icon('maximized_focus_inactive'),
              titlebar_maximized_button_normal_active = titlebar_icon('maximized_normal_active'),
              titlebar_maximized_button_focus_active = titlebar_icon('maximized_focus_active'),

              -- layout icons
              layout_fairh = layout_icon('fairh'),
              layout_fairv = layout_icon('fairv'),
              layout_floating = layout_icon('floating'),
              layout_magnifier = layout_icon('magnifier'),
              layout_max = layout_icon('max'),
              layout_fullscreen = layout_icon('fullscreen'),
              layout_tilebottom = layout_icon('tilebottom'),
              layout_tileleft = layout_icon('tileleft'),
              layout_tile = layout_icon('tile'),
              layout_tiletop = layout_icon('tiletop'),
              layout_spiral = layout_icon('spiral'),
              layout_dwindle = layout_icon('dwindle'),
              layout_cornernw = layout_icon('cornernw'),
              layout_cornerne = layout_icon('cornerne'),
              layout_cornersw = layout_icon('cornersw'),
              layout_cornerse = layout_icon('cornerse'),

              -- awesome icon
              awesome_icon = assets.awesome_icon(
                M.menu_height, c.base02, c.base05
              )
            }

            require('ruled.notification').append_rule {
              rule = { urgency = 'critical' },
              properties = { bg = c.base02, fg = c.base05 }
            }
          end

          return M
        '';
      };
    };
    # users/enderger/feh
    programs.feh = {
      enable = true;
    };
    # users/enderger/qutebrowser
    programs.qutebrowser = {
      enable = true;

      # users/enderger/qutebrowser/keys
      keyBindings = {
        normal = {
          ",m" = "spawn ${pkgs.mpv}/bin/mpv {url}";
        };
      };
      # users/enderger/qutebrowser/quickmarks
      quickmarks = let
        nix-manual = project: branch: "https://nixos.org/manual/${project}/${branch}/";
      in {
        # general sites
        github = "https://github.com";
        sourcehut = "https://sr.ht/";

        # Nix sites
        nixos = nix-manual "nixos" "unstable";
        nixos-stable = nix-manual "nixos" "stable";

        nixpkgs = nix-manual "nixpkgs" "unstable";
        nixpkgs-stable = nix-manual "nixpkgs" "stable";

        nix = nix-manual "nix" "unstable";
        nix-stable = nix-manual "nix" "stable";
      };
      # users/enderger/qutebrowser/searchEngines
      searchEngines = let
        nix-search = type: "https://search.nixos.org/${type}?channel=unstable&from=0&size=30&sort=relevance&query={}";
      in {
        e = "https://ecosia.org/search?q={}";
        gh = "https://github.com/search?q={}";
        np = nix-search "packages";
        no = nix-search "options";
      };

      settings = {
        # users/enderger/qutebrowser/behaviour
        auto_save.session = true;
        changelog_after_upgrade = "never";
        confirm_quit = [ "always" ];

        content = {
          cookies.accept = "no-3rdparty";
          default_encoding = "utf-8";
          headers.do_not_track = true;
          javascript.can_access_clipboard = true;
          pdfjs = true;
          plugins = true;
        };

        editor.command = (lib.splitString " " editor) ++ [ "{file}" ];
        scrolling.smooth = true;
        # users/enderger/qutebrowser/theming
        colors = let
          colour = id: "#${theme-colour id}";

          border = colour: { top = colour; bottom = colour; };
          simpleColour = fg: bg: { fg = colour fg; bg = colour bg; };
        in {
          completion = {
            fg = colour 5;
            odd.bg = colour 1;
            even.bg = colour 0;

            category = {
              fg = colour 10;
              bg = colour 0;
              border = border (colour 0);
            };

            item = {
              selected = {
                fg = colour 5;
                bg = colour 2;
                border = border (colour 2);
                match.fg = colour 11;
              };
            };
            match.fg = colour 11;
            scrollbar = simpleColour 5 0;
          };

          contextmenu = {
            disabled = simpleColour 4 1;
            menu = simpleColour 5 0; 
            selected = simpleColour 5 2;
          };

          downloads = {
            start = simpleColour 0 13;
            stop = simpleColour 0 12;
            error.fg = colour 8;
          };

          hints = {
            fg = colour 0;
            bg = colour 10;
            match.fg = colour 5;
          };

          keyhint = {
            fg = colour 5;
            suffix.fg = colour 5;
            bg = colour 0;
          };

          messages = let
            msgType = fg: bg: border: (simpleColour fg bg) // { border = colour border; };
          in {
            error = msgType 0 8 8;
            warning = msgType 0 14 14;
            info = msgType 5 0 0;
          };

          prompts = {
            fg = colour 5;
            bg = colour 0;
            border = colour 0;
            
            selected = simpleColour 2 5;
          };

          statusbar = {
            normal = simpleColour 11 0;
            insert = simpleColour 0 14;
            passthrough = simpleColour 0 13;
            private = simpleColour 5 0;

            caret = {
              fg = colour 0;
              bg = colour 14;
              selection = simpleColour 0 13;
            };

            progress.bg = colour 13;

            url = {
              fg = colour 5;

              error.fg = colour 8;
              hover.fg = colour 5;

              success = {
                http.fg = colour 12;
                https.fg = colour 11;
              };

              warn.fg = colour 15;
            };
          };

          tabs = {
            bar.bg = colour 0;

            indicator = {
              start = colour 13;
              stop = colour 12;
              error = colour 8;
            };

            odd = simpleColour 5 1;
            even = simpleColour 5 0;

            pinned = {
              odd = simpleColour 7 11;
              even = simpleColour 7 12;

              selected = {
                odd = simpleColour 5 2;
                even = simpleColour 5 2;
              };
            };
          };

          webpage = {
            bg = colour 0;
            preferred_color_scheme = "dark";
          };
        };

        downloads.position = "bottom";

        fonts = {
          default_family = font.name;
          default_size = "${builtins.toString font.size}pt";
        };
      };
    };
    # users/enderger/picom
    services.picom = {
      enable = true;
      blur = true;

      # better Nvidia support
      experimentalBackends = true;
      backend = "glx";
      inactiveOpacity = "0.97";
      vSync = true;

      extraOptions = ''
        unredir-if-possible = true;
        use-damage = true;
        glx-no-stencil = true;
        xrender-sync-fence = true;
      '';
    };
    # users/enderger/xidlehook
    services.xidlehook = {
      enable = true;
      timers = [
        {
          delay = 300;
          command = lock;
        }
        {
          delay = 3600;
          command = "systemctl suspend";
        }
      ];
    };
    # users/enderger/pass
    services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentryFlavor = "qt";
    };
    programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (ext: [ ext.pass-otp ]);
        settings = {
            PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
        };
    };
    services.pass-secret-service.enable = true;
    systemd.user.services.pass-secret-service = {
        Service.Type = "dbus";
        Service.BusName = "org.freedesktop.secrets";
        Unit = let targets = [ "gpg-agent.service" "activate-secrets.service" ]; in {
            Wants = targets;
            After = targets;
            PartOf = [ "graphical-session-pre.target" ];
        };
    };
    programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
            bungcip.better-toml
            editorconfig.editorconfig
            redhat.java
            skellock.just
            arcticicestudio.nord-visual-studio-code
            kahole.magit
            vscodevim.vim
        ];
    };
    # users/enderger/themes
    gtk = {
      enable = true;

      inherit font;
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "ePapirus";
      };
      theme = {
        package = pkgs.nordic;
        name = "Nordic";
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";

      style = {
        package = pkgs.libsForQt5.qtstyleplugins;
        name = "gtk2";
      };
    };

    # Packages
    home.packages = with pkgs; [
      # users/enderger/packages
      ## DEPENDENCIES
      glow
      libsecret
      lxqt.lxqt-policykit
      neovide
      pfetch
      transcrypt

      ## APPLICATIONS
      discord
      exercism
      jetbrains.idea-community
      libreoffice
      libresprite
      nheko-master
      obs-studio
      pcmanfm
      spectacle
      zoom-us

      ## GAMES
      steam
      steam-run
      ckan
      glfw
      minecraft polymc

      ## UTILITIES
      jdk17 gradle
      cargo-expand
      gcc gnumake
      lldb
      lshw
      nix-prefetch-git
      packwiz
      pandoc
      pciutils
      (with fenix; combine [
        default.toolchain
        latest.rust-src
      ])
      ripgrep
      tup
      virt-manager
      wineWowPackages.full winetricks
      xclip
      xorg.xkill
    ];

    home.stateVersion = "22.11";
  };
}
