return {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local home = vim.fn.expand("~") -- Expands the home directory

        require('telescope').setup{
            defaults = {
                file_ignore_patterns = {
                    "%.jpg", "%.jpeg", "%.png", "%.gif", "%.bmp", "%.tiff", "%.webp", "%.kra", -- image formats
                    "%.mp4", "%.mkv", "%.webm", "%.avi", "%.mov", "%.flv", "%.wmv", -- video formats
                    "%.mp3", "%.wav", "%.flac", "%.m4a", -- audio formats
                }
            }
        }

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end
}

