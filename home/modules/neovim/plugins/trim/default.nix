{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install trim for nvim
    plugins = with pkgs.vimPlugins; [{
      plugin = trim-nvim;
      type = "lua";
      config = ''
        ----------------------------------
        -- trim
        ----------------------------------

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
      '';
    }];
  };
}
