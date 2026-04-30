local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Indent/dedent in visual mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Snacks picker
vim.keymap.set('n', '<leader>ff', function() Snacks.picker.files() end, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', function() Snacks.picker.grep() end, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = "Find buffers" })
vim.keymap.set('n', '<leader>gg', function() Snacks.picker.git_status() end, { desc = "Git status" })

-- File explorer
vim.keymap.set('n', '<leader>e', function() Snacks.explorer() end, { desc = "File explorer" })

-- Trouble (diagnostics)
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = "Diagnostics" })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<cr>', { desc = "Quickfix list" })
vim.keymap.set('n', '<leader>xt', '<cmd>Trouble todo toggle<cr>', { desc = "TODO list" })

-- Neogit
vim.keymap.set('n', '<leader>ng', '<cmd>Neogit<cr>', { desc = "Neogit" })
