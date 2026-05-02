require('conform').setup({
    default_format_opts = {
        lsp_format = "fallback",
        timeout_ms = 1000,
    },
    formatters_by_ft = {
        nix     = { "nixfmt" },
        c       = { "clang_format" },
        cpp     = { "clang_format" },
        rust    = { "rustfmt" },
        haskell = { "fourmolu" },
        cuda    = { "clang_format" },
    },
    format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
        vim.b.disable_autoformat = true
    else
        vim.g.disable_autoformat = true
    end
end, { desc = "Disable autoformat-on-save", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
end, { desc = "Enable autoformat-on-save" })
