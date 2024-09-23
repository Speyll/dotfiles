return {
    'brenoprata10/nvim-highlight-colors',
    config = function()
        require('nvim-highlight-colors').setup {
            render = 'background', -- Or 'foreground', depending on your preference
            enable_named_colors = true, -- Enable parsing of named colors
            enable_tailwind = true, -- Optional: Enable TailwindCSS color classes
        }
    end
}

