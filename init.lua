-- Options for Vim --
vim.opt.relativenumber =	true
vim.opt.number =		true
vim.opt.hlsearch =		true
vim.opt.clipboard =		"unnamedplus"
vim.opt.cursorline = 		true
vim.opt.tabstop = 		4
vim.opt.shiftwidth = 		4
vim.opt.softtabstop = 		4
vim.opt.expandtab = 		true
vim.opt.termguicolors = 	true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        "NvChad/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = {
            filetypes = { "*" },
            user_default_options = {
                RGB = true,          -- #RGB hex codes
                RRGGBB = true,        -- #RRGGBB hex codes
                names = false,       -- "Name" codes like Blue or red
                RRGGBBAA = true,      -- #RRGGBBAA hex codes
                AARRGGBB = true,      -- 0xAARRGGBB hex codes
                rgb_fn = true,       -- CSS rgb() and rgba() functions
                hsl_fn = true,       -- CSS hsl() and hsla() functions
                css = true,          -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn = true,       -- CSS v4 functional notation like rgb(0 0 0 / 0.5)
                -- Available modes: foreground, background,  virtualtext
                mode = "background", -- Set the display mode.
                tailwind = true,     -- Enable tailwind colors
                sass = { enable = true, parsers = { "css" }, }, -- Enable sass colors
            },
        },
        {
            "neoclide/coc.nvim",
            branch = "release",
            lazy = false,
        },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
            config = function() 
                require('lualine').setup {
                    options = { theme  = 'auto' },
                }
            end,
        },
        {
            'nvim-tree/nvim-tree.lua',
            config = function()
                require("nvim-tree").setup()
            end
        },
        {
            "scottmckendry/cyberdream.nvim",
            lazy = false,
            priority = 1000,
        },
        {
            -- amongst your other plugins
            {'akinsho/toggleterm.nvim', version = "*", config = true}
            -- or
        },
        { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...}
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})



-- Use Tab for trigger completion with characters ahead and navigate
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
vim.keymap.set("i", "<S-TAB>", 'coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"', opts)

-- Функция для проверки символа перед курсором (нужна для корректной работы Tab)
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end
-- Make Enter to accept selected completion item
vim.keymap.set("i", "<CR>", 'coc#pum#visible() ? coc#pum#confirm() : "\\<C-g>u\\<CR>\\<c-r>=coc#on_enter()\\<CR>"', opts)

-- GoTo code navigation
vim.keymap.set("n", "gd", "<Plug>(coc-definition)", {silent = true})
vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", {silent = true})
vim.keymap.set("n", "gr", "<Plug>(coc-references)", {silent = true})

-- Use K to show documentation in preview window
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.fn['coc#rpc#ready']() then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
vim.keymap.set("n", "K", "<CMD>lua _G.show_docs()<CR>", {silent = true})
vim.keymap.set("n", "<leader>t", "<CMD>ToggleTerm direction=float<CR>")
vim.keymap.set("n", "<leader>r", "<CMD>ToggleTerm direction=horizontal<CR>")
-- Создаем удобную функцию для переключения состояния дерева
local function toggle_nvim_tree()
    -- Проверяем, открыт ли буфер nvim-tree
    if vim.fn.bufname():match('NvimTree_') then
        -- Если открыт — закрываем с помощью встроенного API
        require('nvim-tree.api').tree.close()
    else
        -- Если закрыт — открываем и находим текущий файл
        require('nvim-tree.api').tree.toggle()
    end
end

-- Назначаем горячую клавишу, например, <Leader>e
-- Замените '<Leader>e' на любую удобную вам комбинацию
vim.keymap.set('n', '<Leader>e', toggle_nvim_tree, { desc = 'Переключить nvim-tree' })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#F0F0F0" })

vim.keymap.set('n', 'J', '<CMD>tabprevious<CR>', { noremap = true, silent = true })

vim.keymap.set('n', 'L', '<CMD>tabnext<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<Leader>y', '<CMD>tabnew<CR>')
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], {buffer = 0, silent = true})
vim.cmd[[colorscheme cyberdream]]
