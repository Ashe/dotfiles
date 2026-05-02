require('notify').setup({
    render = "compact",
    on_open = function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    end,
})

-- Replace vim.notify globally with nvim-notify
vim.notify = require('notify')
