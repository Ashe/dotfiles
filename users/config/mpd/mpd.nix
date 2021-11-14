{
  # Configure mpd music server
  services.mpd = {
    
    # Enable mpd
    enable = true;

    # Specify music location
    musicDirectory = ~/Music;

    # Configure server networking settings
    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
  };
}
