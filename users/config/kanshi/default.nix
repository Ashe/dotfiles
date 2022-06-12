
{ ... }:

{
  # Configure Kanshi, a wayland daemon that automatically configures outputs
  services.kanshi = {

      # Enable Kanshi
      enable = true;

      # Setup profiles for each use case
      profiles = {

          # Profile for using a single Samsung Odyssey super-ultrawide monitor
          odyssey = {

              # Single output for this profile
              outputs = [{
                  criteria = "Samsung Electric Company LC49G95T H4ZN701223";
                  mode = "5120x1440@240Hz";
                  position = "0,0";
                  scale = null;
                  status = "enable";
                  transform = "normal";
              }];
          };
      };
  };
}
