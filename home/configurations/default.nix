{ self, ... } @ inputs: {
  "ashe@athena" = self.lib.mkHome "ashe" "athena" "x86_64-linux";
}
