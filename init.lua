-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- map leader to space
vim.g.mapleader = " "

-- show line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- setup tabstop
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2

vim.opt.termguicolors = true

vim.opt.colorcolumn = "80"

vim.opt.scrolloff = 8

vim.opt.updatetime = 50

-- allocate space for sign column and line numbers
vim.opt.signcolumn = "yes"
vim.opt.numberwidth = 1

-- move highlited line in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', 'J', "mzJ`z")

-- keep coursor in middle of screen on half page jump
vim.keymap.set('n', '<C-u>', "<C-u>zz")
vim.keymap.set('n', '<C-d>', "<C-d>zz")

-- preserve buffer on replace
vim.keymap.set('x', 'p', '"_dP')

-- yank to plus register
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+y')

-- delete without yangking
vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')

-- noop Q
vim.keymap.set('n', 'Q', '<nop>')

-- format whole file
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end)

-- make current file executable
vim.keymap.set("n", "<leader>x", function()
  vim.cmd("!chmod +x %")
end)

-- init lazy.nvim
require("lazy").setup({
  { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
  "fatih/vim-go",
  "github/copilot.vim",
  "preservim/nerdtree",
  "tiagofumo/vim-nerdtree-syntax-highlight",
  {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.2',
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
  "mbbill/undotree",
  "tpope/vim-fugitive",
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'L3MON4D3/LuaSnip' },
    }
  }
})

-- colorscheme
vim.cmd.colorscheme "catppuccin"

-- setup nerdtree
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeDirArrowExpandable = "▸"
vim.g.NERDTreeDirArrowCollapsible = "▾"
vim.g.NERDTreeDirArrows = 1
vim.g.NERDTreeWinSize = 30
vim.g.NERDTreeIgnore = { ".git", ".cache" }
vim.g.NERDTreeShowLineNumbers = 1

-- bind double leader to nerdtree
vim.api.nvim_set_keymap("n", "<leader><leader>", ":NERDTreeToggle<CR>", { noremap = true, silent = true })

-- setup telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pg', builtin.live_grep, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})

-- setup treesitter
require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua",
    "vim", "vimdoc", "typescript",
    "javascript",
    "json", "yaml", "html",
    "css", "bash", "go",
    "rust" },

  sync_install = false,

  auto_install = true,

  ignore_install = {},

  modules = {},

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}


-- undotree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, {})

-- fugitive
vim.keymap.set('n', '<leader>gs', vim.cmd.Git, {})

-- lsp
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<C-h>', vim.lsp.buf.signature_help, opts)
end)

lsp.set_sign_icons({
  error = "E",
  warning = "W",
  hint = "H",
  information = "I"
})

lsp.setup()

local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),

    ['<C-y>'] = cmp.mapping.confirm({ select = true }),

    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
  }
})

require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "rust_analyzer", "gopls", "tsserver", "eslint" },
}

local lspconfig = require('lspconfig')

-- lua language server
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

local util = require 'lspconfig/util'

-- go language server
lspconfig.gopls.setup {
  filetypes = { "go", "gomod" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}
