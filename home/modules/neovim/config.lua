----------------------------------
-- General
----------------------------------

-- Enable mouse control
vim.opt.mouse = "a"

-- Make sure swap and backup files are created
vim.opt.backup = true
vim.opt.swapfile = true
vim.opt.directory = os.getenv("HOME") .. "/.local/share/nvim/cache"
vim.opt.backupdir = os.getenv("HOME") .. "/.local/share/nvim/cache"

-- Show column guideline to keep code within 80 lines
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.colorcolumn = "81"

-- Spellchecking
vim.opt.spelllang = "en"

-- Make terminal title same as the file you're editing
vim.opt.title = true

-- Tabs are 2 spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Autocomplete interface
vim.opt.wildmenu = true

-- Show matching parenthesis
vim.opt.showmatch = true

-- Ignores all the 'hit-enter' prompts
-- -c prevents messages being given for ins-completion
vim.opt.shortmess = vim.o.shortmess .. "c"

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appear/become resolved
vim.opt.signcolumn = "yes"

-- Change decorative characters
-- Also prevent '~' from showing on blank lines
vim.opt.fillchars = {
  horiz = '━',
  horizup = '┻',
  horizdown = '┳',
  vert = '┃',
  vertleft  = '┫',
  vertright = '┣',
  verthoriz = '╋',
  fold = ' ',
  eob = ' ',
  msgsep = '‾'
}

----------------------------------
-- Keybindings
----------------------------------

-- Set leader key to space
vim.g.mapleader = " "

-- Reload neovim config
vim.keymap.set("n", "<leader><S-BS>", "<Cmd>so ~/.config/nvim/init.lua<CR>", { desc="Reload config" })

-- Save file with leader-w
vim.keymap.set("n", "<leader>w", "<Cmd>w<CR>", { desc="Save file" })

-- Copy to clipboard
vim.opt.clipboard:append { "unnamed", "unnamedplus" }
vim.keymap.set({"n", "v"}, "<leader>y", "\"+y", { desc="Copy" })
vim.keymap.set("n", "<leader>Y", "\"+yg_", { desc="Copy rest" })

-- Paste from clipboard
vim.keymap.set({"n", "v"}, "<leader>P", "\"+P", { desc="Paste before" })
vim.keymap.set({"n", "v"}, "<leader>p", "\"+p", { desc="Paste after" })

-- Delete into the void
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d", { desc="Void delete" })
vim.keymap.set("n", "<leader>D", "\"_dd", { desc="Void line to void" })

-- Move block up and down
vim.keymap.set("v", "K", "<Cmd>m '<-2<CR>gv=gv", { desc="Move block up" })
vim.keymap.set("v", "J", "<Cmd>m '>+1<CR>gv=gv", { desc="Move block down" })

-- Keep cursor in middle of screen when half-page-jumping
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc="Half-page up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc="Half-page down" })

-- Set up text replacement macro
vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc="Substitute" })

-- Improve window navigation keybindings, especially in terminal mode
vim.keymap.set({"n", "t"}, "<C-w>h", "<C-\\><C-n><C-w>h", { desc="Move focus left" })
vim.keymap.set({"n", "t"}, "<C-h>", "<C-\\><C-n><C-w>h", { desc="Move focus left" })
vim.keymap.set({"n", "t"}, "<C-w>j", "<C-\\><C-n><C-w>j", { desc="Move focus down" })
vim.keymap.set({"n", "t"}, "<C-j>", "<C-\\><C-n><C-w>j", { desc="Move focus down" })
vim.keymap.set({"n", "t"}, "<C-w>k", "<C-\\><C-n><C-w>k", { desc="Move focus up" })
vim.keymap.set({"n", "t"}, "<C-k>", "<C-\\><C-n><C-w>k", { desc="Move focus up" })
vim.keymap.set({"n", "t"}, "<C-w>l", "<C-\\><C-n><C-w>l", { desc="Move focus right" })
vim.keymap.set({"n", "t"}, "<C-l>", "<C-\\><C-n><C-w>l", { desc="Move focus right" })
vim.keymap.set("t", "<C-w>w", "<C-\\><C-n>", { desc="Unfocus terminal" })

-- Tab navigation
require('which-key').register({ ["<Tab>"] = { name = "Tabs.." } }, { prefix = "<leader>" })
vim.keymap.set("n", "<Tab>", "<Cmd>tabnext<CR>", { desc="Next tab" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>tabprevious<CR>", { desc="Next tab" })
vim.keymap.set("n", "<C-Backspace>", "<Cmd>tabclose<CR>", { desc="Close tab" })
vim.keymap.set("n", "<leader><Tab>n", "<Cmd>tab split<CR>", { desc="New tab" })
vim.keymap.set("n", "<leader><Tab><Backspace>", "<Cmd>tabclose<CR>", { desc="Close tab" })
vim.keymap.set("n", "<leader><Tab>o", "<Cmd>tabonly<CR>", { desc="Close other tabs" })
vim.keymap.set({"n", "t"}, "<C-Tab>n", "<Cmd>tab split<CR>", { desc="New tab" })
vim.keymap.set({"n", "t"}, "<C-Tab><Backspace>", "<Cmd>tabclose<CR>", { desc="Close tab" })
vim.keymap.set({"n", "t"}, "<C-Tab>o", "<Cmd>tabonly<CR>", { desc="Close other tabs" })

----------------------------------
-- Appearance
----------------------------------

local ok, _ = pcall(vim.cmd, 'colorscheme <colourscheme>')
if not ok then
  vim.cmd 'colorscheme default'
end

----------------------------------
-- Plugin-preparation
----------------------------------

-- nvim-tree: Disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
