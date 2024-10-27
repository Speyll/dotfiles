return {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-file-browser.nvim',  -- Add this line
    },
    config = function()
        require('telescope').setup{
            defaults = {
                file_ignore_patterns = {
                    "%.jpg", "%.jpeg", "%.png", "%.gif", "%.bmp", "%.tiff", "%.webp", "%.kra",
                    "%.mp4", "%.mkv", "%.webm", "%.avi", "%.mov", "%.flv", "%.wmv",
                    "%.mp3", "%.wav", "%.flac", "%.m4a",
                    "node_modules/", "vendor/", "%.lock", "%.log",
                },
                hidden = true,
            },
            extensions = {
                file_browser = {
                    -- Configuration for the file browser
                    theme = "dropdown",
                    hijack_netrw = true,
                },
            },
        }

        require('telescope').load_extension('file_browser')  -- Load the file browser extension

        local builtin = require('telescope.builtin')

        -- Function to open the file browser
        local function find_files_in_directory()
            require('telescope').extensions.file_browser.file_browser({
                path = vim.fn.input("Search in directory (leave empty for current): ", vim.fn.getcwd()),
                cwd = vim.fn.getcwd(),
                hidden = true,
                respect_git_ignore = false,
                attach_mappings = function(_, map)
                    map('i', '<C-t>', function()  -- Optional: Create a mapping for opening files in new tab
                        local selection = require('telescope.actions.state').get_selected_entry()
                        if selection then
                            vim.cmd('tabnew ' .. selection.path)
                        end
                    end)
                    return true
                end,
            })
        end

        -- Key mappings
        vim.keymap.set('n', '<leader>pf', find_files_in_directory, {})
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
