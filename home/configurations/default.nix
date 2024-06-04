{ self, ... } : {
  "ashe@athena" = self.lib.mkHome "ashe" "athena" "x86_64-linux";
  "ashe@artemis" = self.lib.mkHome "ashe" "artemis" "x86_64-linux";
  "deck@steamdeck" = self.lib.mkHome "deck" "steamdeck" "x86_64-linux";
}
