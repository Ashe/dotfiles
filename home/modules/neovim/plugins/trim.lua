require('trim').setup({
    patterns = {

        -- Remove unwanted spaces
        [[%s/\s\+$//e]],

        -- Trim last line
        [[%s/\($\n\s*\)\+\%$//]],

        -- Trim first line
        [[%s/\%^\n\+//]],
    },
})
