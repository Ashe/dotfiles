# Export default programs
export EDITOR='nvim'
export TERMINAL='urxvt'
export BROWSER='firefox'
export FILE='ranger'

# Append the path to include local scripts
export PATH=$PATH:/usr/bin:
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.scripts
export PATH=$PATH:$HOME/.gem/ruby/2.6.0/bin
export PATH=$PATH:$HOME/.config/bspwm
export PATH=$PATH:$HOME/.dotnet/tools

# Path to .NET Core SDKs
export MSBuildSDKsPath=/opt/dotnet/sdk/$(dotnet --version)/Sdks
