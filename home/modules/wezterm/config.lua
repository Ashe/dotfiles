-- Configure wezterm
return {

	-- Customise appearance
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 14.0,
	color_scheme = "Tokyo Night",
	front_end = "WebGpu",

	-- Disable fancy tab bar
	use_fancy_tab_bar = false,

	-- Disable sounds
	audible_bell = "Disabled",

	-- Customise keybindings
	keys = {

		-- Command palette
		{ key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette },

		-- Tabs
		{ key = "Enter", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
		{ key = "Backspace", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
		{ key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ShowTabNavigator },
		{ key = "p", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "n", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },

		-- Copy / paste
		{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
		{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },

		-- Scrollback
		{ key = "u", mods = "CTRL|SHIFT", action = wezterm.action.ScrollByPage(-1) },
		{ key = "d", mods = "CTRL|SHIFT", action = wezterm.action.ScrollByPage(1) },
		{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.ScrollToTop },
		{ key = "g", mods = "CTRL|SHIFT", action = wezterm.action.ScrollToBottom },

		-- Emoji / character picker
		{
			key = "e",
			mods = "CTRL|SHIFT",
			action = wezterm.action.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
		},
	},
}
