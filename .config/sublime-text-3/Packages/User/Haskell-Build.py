import sublime
import sublime_plugin

import os
import glob

from Default.exec import ExecCommand

class HaskellExecCommand(ExecCommand):
    def find_cabal(self, view):
        if view is None or view.file_name() is None:
            return ""

        # Starting at the path of the current file, keep going up one folder
        # until we land in a folder with a cabal file in it, or we hit the
        # root.
        cwd = os.path.dirname(view.file_name())
        while cwd != "/" and not glob.glob(os.path.join(cwd, "*.cabal")):
            cwd = os.path.abspath(cwd + "/../")

        # We didn't find a cabal file, so return the empty string.
        if cwd == "/":
            return ""

        # Return the found location
        return cwd

    def run(self, **kwargs):
        # Create a build variable named $cabal that specifies the path that
        # contains the first found cabal file in the folder structure under
        # the folder of the current file; this will be the empty string if
        # there is no such file or the current view doesn't have a filename.
        variables = {"cabal": self.find_cabal(self.window.active_view())}

        # Expand out the variable in the target build keys
        for key in ('shell_cmd', 'cmd', 'working_dir'):
            if key in kwargs:
                kwargs[key] = sublime.expand_variables(kwargs[key], variables)

        # Execute the build with the new arguments
        super().run(**kwargs)