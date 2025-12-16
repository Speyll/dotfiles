return {
    'ojroques/nvim-hardline',
    config = function()
        require('hardline').setup {
            bufferline = false,  -- disable bufferline
            bufferline_settings = {
                exclude_terminal = false,  -- don't show terminal buffers in bufferline
                show_index = false,        -- show buffer indexes (not the actual buffer numbers) in bufferline
            },
            theme = 'custom',
            -- Start flavours
            custom_theme = {
                text = {gui = "#282828", cterm = "235", cterm16 = "0"},
                normal = {gui = "#83a598", cterm = "109", cterm16 = "6"},
                insert = {gui = "#b8bb26", cterm = "142", cterm16 = "2"},
                replace = {gui = "#fabd2f", cterm = "214", cterm16 = "3"},
                inactive_comment = {gui = "NONE", cterm = "NONE", cterm16 = "NONE"},
                inactive_cursor = {gui = "NONE", cterm = "NONE", cterm16 = "NONE"},
                inactive_menu = {gui = "NONE", cterm = "NONE", cterm16 = "NONE"},
                visual = {gui = "#8ec07c", cterm = "108", cterm16 = "6"},
                command = {gui = "#d3869b", cterm = "132", cterm16 = "5"},
                alt_text = {gui = "#ebdbb2", cterm = "223", cterm16 = "7"},
                warning = {gui = "#fb4934", cterm = "167", cterm16 = "1"},
            },
            -- End flavours
            sections = {         -- define sections
                {class = 'mode', item = require('hardline.parts.mode').get_item},
                {class = 'high', item = require('hardline.parts.git').get_item, hide = 100},
                {class = 'med', item = require('hardline.parts.filename').get_item},
                '%<',
                {class = 'med', item = '%='},
                {class = 'low', item = require('hardline.parts.wordcount').get_item, hide = 100},
                {class = 'error', item = require('hardline.parts.lsp').get_error},
                {class = 'warning', item = require('hardline.parts.lsp').get_warning},
                {class = 'warning', item = require('hardline.parts.whitespace').get_item},
                {class = 'high', item = require('hardline.parts.filetype').get_item, hide = 60},
                {class = 'mode', item = require('hardline.parts.line').get_item},
            },
        }
    end
}
