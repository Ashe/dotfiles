{ pkgs, ... }:

{
  # Configure ncmpcpp music player
  programs.ncmpcpp = {

    # Enable ncmpcpp
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };

    # Configure ncmpcpp
    settings = {

      # Global
      mouse_support = "yes";
      mouse_list_scroll_whole_page = "yes";
      lines_scrolled = "1";
      message_delay_time = "3";
      playlist_shorten_total_times = "yes";
      autocenter_mode = "yes";
      centered_cursor = "yes";
      follow_now_playing_lyrics = "yes";
      ignore_leading_the = "yes";
      external_editor = "$EDITOR";
      colors_enabled = "yes";

      # UI visibility
      header_visibility = "no";
      statusbar_visibility = "yes";
      titles_visibility = "yes";
      enable_window_title = "yes";

      # UI appearance
      user_interface = "classic";
      playlist_display_mode = "columns";
      browser_display_mode = "columns";
      search_engine_display_mode = "columns";
      playlist_editor_display_mode = "columns";
      display_remaining_time = "yes";
      progressbar_look = "─╼";
      song_list_format = "{%a - }{%t}|{$5%f$9}$R{$7(%l)$9}";
      song_status_format = "$2%a $1• $3%t $1• $4%b {(Disc %d) }$1• $5%y$1";
      song_window_title_format = "{%a - }{%t}|{%f}";
      song_columns_list_format = "(5f)[blue]{l} (33)[cyan]{t} (32)[green]{a} (30)[magenta]{b}";
    };

    # Configure keybindings
    bindings = [

      # Scrolling down
      { key = "j"; command = "scroll_down"; }
      { key = "J"; 
        command = [
          "select_item" 
          "scroll_down" 
        ]; 
      }

      # Scrolling up
      { key = "k"; command = "scroll_up"; }
      { key = "K"; 
        command = [
          "select_item" 
          "scroll_up"
        ]; 
      }

      # Column navigation
      { key = "h"; command = "previous_column"; }
      { key = "l"; command = "next_column"; }

      # Screen navigation
      { key = "h"; command = "master_screen"; }
      { key = "l"; command = "slave_screen"; }

      # Volume control
      { key = "h"; command = "volume_down"; }
      { key = "l"; command = "volume_up"; }

      # Lyrics
      { key = "L"; command = "show_lyrics"; }
    ];
  };
}
