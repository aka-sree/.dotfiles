-- Fuzzy Finder (files, lsp, etc)
return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- Fuzzy Finder Algorithm which requires local dependencies to be built.
        -- Only load if `make` is available. Make sure you have the system
        -- requirements installed.
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            -- NOTE: If you are having trouble with this installation,
            --       refer to the README for telescope-fzf-native for more instructions.
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
    },
    opts = {
        defaults = {
            mappings = {
                i = {
                    ['<C-u>'] = false,
                    ['<C-d>'] = false,
                },
            },
        },
    },
    config = function(_, opts)
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        telescope.setup(opts)
        pcall(telescope.load_extension, 'fzf')

        -- LazyVim-style keymaps
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by Grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find Help' })
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Find Recent Files' })
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find Word under cursor' })
        vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Find Diagnostics' })
        vim.keymap.set('n', '<leader>fc', builtin.resume, { desc = 'Find Continue (resume)' })
        vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = 'Find Buffers' })
        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
            })
        end, { desc = 'Fuzzily search in current buffer' })

        -- Git
        vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Git Files' })
        vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git Commits' })
        vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })
    end
}

