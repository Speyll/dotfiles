return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- The new rewrite branch
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    -- Configuration now happens directly in 'opts'
    opts = {
        ensure_installed = {
            "json", "javascript", "typescript", "tsx", "yaml",
            "html", "css", "markdown", "markdown_inline", "bash",
            "lua", "vim", "dockerfile", "gitignore", "c", "rust",
        },
        highlight = { enable = true },
        indent = { enable = true },
    },
    config = function(_, opts)
        -- In the 'main' branch, use the core module directly
        require("nvim-treesitter").setup(opts)
    end,
}
