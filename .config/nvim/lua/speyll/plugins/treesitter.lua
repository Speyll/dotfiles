return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- rewrite branch; requires Neovim >= 0.12
    lazy = false, -- the 'main' branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        -- Parser set declared via the 'main' branch API (replaces ensure_installed).
        require("nvim-treesitter").install({
            "json", "javascript", "typescript", "tsx", "yaml",
            "html", "css", "markdown", "markdown_inline", "bash",
            "lua", "vim", "dockerfile", "gitignore", "c", "rust",
        })

        -- Highlighting is provided by Neovim; enable it per filetype where a
        -- parser is available, and turn on Treesitter indentation for that buffer.
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if lang and vim.treesitter.language.add(lang) then
                    vim.treesitter.start(args.buf, lang)
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
