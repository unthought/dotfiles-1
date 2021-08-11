/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
{ pkgs, inputs, lib, ... }:
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
  font = "FiraCode Nerd Font";
  term = "alacritty";
  browser = "qutebrowser";
  lock = "${pkgs.i3lock}/bin/i3lock -n -c ${theme-colour 0}";
  editor = "neovide";
in {
  # users/enderger/userOptions
  environment.shells = [ pkgs.nushell ];
  users.users.enderger = {
    isNormalUser = true;
    shell = pkgs.nushell;
    group = "wheel";
    extraGroups = [ "docker" ];
    inherit (secrets) hashedPassword;
  };

  services.xserver.windowManager = {
    # users/enderger/windowManagers
    awesome.enable = true;
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
        filesize_format = "MiB";
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
        env.TERM = "alacritty";
        font.normal.family = font;

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
        vim-polyglot
        vim-vsnip vim-vsnip-integ
        which-key-nvim
        # users/enderger/neovim/plugins.editing
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
        nvim-lightbulb
        nvim-treesitter-context
        nvim-ts-rainbow
        # users/enderger/neovim/plugins.integrations
        gitsigns-nvim
        glow-nvim
        neogit
        nvim-toggleterm-lua
        vim-test
        # users/enderger/neovim/plugins.ui
        feline-nvim
        nvim-base16
        nvim-web-devicons nvim-nonicons
      ];

      extraPackages = with pkgs; [
        # users/enderger/neovim/plugins/packages
        deno nodePackages.vscode-html-languageserver-bin nodePackages.vscode-css-languageserver-bin
        git
        rnix-lsp
        (with fenix; combine [
          default.rustfmt-preview default.clippy-preview rust-analyzer
        ])
      ];
      
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
          opt.guifont = '${font}' -- interpolated via Nix
          opt.number = true
          opt.showmode = false
          opt.signcolumn = 'yes:3'

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
          opt.mouse = 'a'
          opt.spell = true
          opt.title = true
        '';
        keys = ''
          -- users/enderger/neovim/config/keys
          local map = require('lib').map
          local ts = require('telescope.builtin')

          -- leaders
          vim.g.mapleader = ' '
          vim.g.maplocalleader = ','

          -- which-key setup
          local wk = require('which-key')
          wk.setup {}

          -- insert mappings
          map('jk', '<Cmd>stopinsert<CR>', 'i')
          map('<C-Leader>', '<C-o><Leader>', 'i')

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
            t = {
              "<Cmd>TestSuite<CR>",
              "tests",
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
          }
          wk.register(action_keys, { mode = "n", prefix = "<leader>c" })

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

          -- LSP
          local lsp = require('lspconfig')

          --- Capabilities
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.completion.completionItem.snippetSupport = true

          --- Deno
          lsp.denols.setup {
            capabilities = capabilities,
          }

          --- HTML
          lsp.html.setup {
            capabilities = capabilities,
          }

          --- CSS
          lsp.cssls.setup {
            capabilities = capabilities,
          }

          --- Nix
          lsp.rnix.setup {
            capabilities = capabilities,
          }

          --- Rust
          lsp.rust_analyzer.setup {
            capabilities = capabilities,
            settings = {
              ['rust-analyzer'] = {
                -- use Clippy
                checkOnSave = { command = 'clippy' },
              },
            }
          }

          -- Completion
          lib.autocmd('BufEnter', 'lua require(\'completion\').on_attach()')
          opt.shortmess:append('c')
          g.completion_matching_smart_case = true

          -- Snippets
          g.completion_enable_snippet = 'vim-vsnip'

          -- Syntax
          g.markdown_fenced_languages = {'nix', 'lua', 'rust'}

          -- Treesitter
          local ts = require('nvim-treesitter.configs')
          local ts_enabled = { enable = true }
          ts.setup {
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
          require('treesitter-context.config').setup {
            enable = true,
          }

          opt.foldexpr = vim.fn['nvim_treesitter#foldexpr']()

          -- Formatting
          lib.autocmd('BufWritePre', 'undojoin | Neoformat')

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
            shading_factor = 1,
            open_mapping = "<C-S-t>",
          }

          -- Testing
          g['test#strategy'] = 'neovim'
        '';
        ui = ''
          -- users/enderger/neovim/config/ui
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
          local feline_vi = require('feline.providers.vi_mode')
          local feline_config = {
            components = {
              left = {
                active = {
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
                    provider = 'position',

                    left_sep = '(',
                    right_sep = ')',
                  },
                }, 
                inactive = {
                  { provider = 'file_info' },
                },
              },
              mid = {
                active = {
                  -- LSP info
                  {
                    provider = 'diagnostic_errors',
                    enabled = function() return feline_lsp.diagnostics_exist('Error') end,
                    hl = { fg = 'base08' },
                  },
                  {
                    provider = 'diagnostic_warnings',
                    enabled = function() return feline_lsp.diagnostics_exist('Warning') end,
                    hl = { fg = 'base0A' },
                  },
                  {
                    provider = 'diagnostic_hints',
                    enabled = function() return feline_lsp.diagnostics_exist('Hint') end,
                    hl = { fg = 'base0C' },
                  },
                  {
                    provider = 'diagnostic_info',
                    enabled = function() return feline_lsp.diagnostics_exist('Information') end,
                    hl = { fg = 'base0D' },
                  },
                },
                inactive = {},
              },
              right = {
                active = {
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
                inactive = {},
              },
            },
            properties = {
              force_inactive = {
                bufnames = {},
                buftypes = {
                  'terminal',
                },
                filetypes = {
                  'NeogitStatus',
                },
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
            default_bg = 'base01',
            default_fg = 'base04',
            colors = colours,
            components = feline_config.components,
            properties = feline_config.properties,
            vi_mode_colors = feline_config.mode_colours,
          }
        '';
        /* Will uncomment when needed
        misc = ''
  <<<users/enderger/neovim/config/misc>>>
        '';
        */
      };
    };
    # users/enderger/git
    programs.git = {
      enable = true;
      userEmail = "endergeryt@gmail.com";
      userName = "Enderger";
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

          require('init').setup()
          require('keys').setup()
          require('rules').setup()
          require('screens').setup()
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
            spawn('systemctl --user start picom xidlehook')
            spawn('feh --bg-scale '..(require('beautiful').wallpaper))
            spawn('lxqt-policykit')
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

              awful.key {
                modifiers = { M.leader, M.modifier },
                keygroup = 'vimkeys',

                on_press = awful.client.swap.global_bydirection,

                description = 'Move client',
                group = M.groups.client,
              },

              --- screens
              awful.key {
                modifiers = { M.leader },
                keygroup = 'vimcycle',
                
                on_press = awful.screen.focus_relative,

                description = 'Focus screen',
                group = M.groups.wm,
              },

              awful.key {
                modifiers = { M.leader, M.modifier },
                keygroup = 'vimcycle',
                
                on_press = function(direction)
                  local c = awful.client.focused

                  if c then
                    c:move_to_screen(c.screen.index + direction)
                  end
                end,

                description = 'Move to screen',
                group = M.groups.client,
              },

              --- tags
              awful.key {
                modifiers = { M.leader, M.alternate },
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

              awful.key {
                modifiers = { M.leader, M.modifier },
                keygroup = 'numrow',

                on_press = function (idx)
                  local c = awful.client.foucs
                  
                  if c and c.screen.tags[idx] then
                    c:move_to_tag(c.screen.tags[idx])
                  end
                end,

                description = 'Move to tag',
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
          M.font = '${font} 11'
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
          default_family = font;
          default_size = "11pt";
        };
      };
    };
    # users/enderger/picom
    services.picom = {
      enable = true;

      backend = "xrender";
      blur = true;
      inactiveOpacity = "0.8";

      extraOptions = ''
        unredir-if-possible = false;
        vsync = true;
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

    # Packages
    home.packages = with pkgs; [
      # users/enderger/packages
      ## DEPENDENCIES
      lxqt.lxqt-policykit
      neovide
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      pfetch
      transcrypt

      ## APPLICATIONS
      discord-ptb
      etcher
      exercism
      pcmanfm
      spectacle
      zoom-us

      ## GAMES
      ckan
      multimc

      ## UTILITIES
      adoptopenjdk-openj9-bin-11
      gnumake
      lshw
      nix-prefetch-git
      pandoc
      pciutils
      xorg.xkill
    ];
  };
}
