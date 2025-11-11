{
  # Read and parse a JSON file while stripping out // comments
  fromJsonFile = filepath: let
    # Read the file content
    fileContent = builtins.readFile filepath;

    # Split into lines
    lines = builtins.split "\n" fileContent;

    # Filter out comment lines starting with //
    filterComments = line:
    if builtins.isString line then
        let trimmed = builtins.replaceStrings [" " "\t"] ["" ""] line;
        in !(builtins.match "//.*" trimmed != null)
    else
        true;

    # Reconstruct the file without comment lines
    filteredLines = builtins.filter filterComments lines;
    cleanContent = builtins.concatStringsSep "\n"
    (builtins.filter builtins.isString filteredLines);
  in
    builtins.fromJSON cleanContent;
}
