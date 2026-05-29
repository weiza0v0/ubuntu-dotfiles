-- ==========================================
-- 1. 基础设置
-- ==========================================
vim.g.mapleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.swapfile = false

-- 剪贴板: Wayland 下显式指定用 xclip
vim.g.clipboard = {
  name = "xclip",
  copy = {
    ["+"] = "xclip -selection clipboard",
    ["*"] = "xclip -selection primary",
  },
  paste = {
    ["+"] = "xclip -selection clipboard -o",
    ["*"] = "xclip -selection primary -o",
  },
  cache_enabled = 0,
}

-- ==========================================
-- 2. 插件管理器 (lazy.nvim)
-- ==========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================
-- 3. 插件配置
-- ==========================================
require("lazy").setup({
    -- 主题
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                transparent_background = true,
                term_colors = true,
            })
            vim.cmd.colorscheme "catppuccin"
        end
    },

    -- LSP 配置
    { "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp"
      },
      config = function()
          require("mason").setup()
          local servers = { "pyright", "clangd", "lua_ls" }
          require("mason-lspconfig").setup({ ensure_installed = servers })

          local capabilities = require('cmp_nvim_lsp').default_capabilities()

          for _, server_name in ipairs(servers) do
              local builtin_config = vim.lsp.config[server_name]

              if builtin_config then
                  builtin_config.capabilities = vim.tbl_deep_extend(
                      "force",
                      builtin_config.capabilities or {},
                      capabilities
                  )
                  vim.lsp.enable(server_name)
              else
                  pcall(function()
                      require('lspconfig')[server_name].setup({
                          capabilities = capabilities,
                      })
                  end)
              end
          end
      end
    },

    -- 语法高亮
    { "nvim-treesitter/nvim-treesitter", build = function() vim.cmd("TSUpdate") end,
      config = function()
          pcall(function()
              require("nvim-treesitter.configs").setup({
                  ensure_installed = { "lua", "python", "c" },
                  highlight = { enable = true },
              })
          end)
      end
    },

    -- 补全引擎
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                })
            })
        end
    },
    { "akinsho/toggleterm.nvim", config = true },
    { "christoomey/vim-tmux-navigator" }
})

-- ==========================================
-- 4. 输入法自动切换 (fcitx5)
-- ==========================================
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:[iR]",
  callback = function()
    vim.fn.system({ "fcitx5-remote", "-o" })
  end
})
-- 离开插入/替换模式(回到普通/可视模式) → 切到英文
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "[iR]:[nvV]",
  callback = function()
    vim.fn.system({ "fcitx5-remote", "-c" })
  end
})
-- 进入命令行模式也切英文
vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function()
    vim.fn.system({ "fcitx5-remote", "-c" })
  end
})

-- ==========================================
-- 5. 全局快捷键
-- ==========================================
vim.keymap.set('n', '<leader>qq', '<cmd>qa!<CR>')
