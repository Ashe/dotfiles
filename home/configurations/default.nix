{ self, ... }:
{
  "deck@steamdeck" = self.lib.mkHome "deck" "steamdeck" "x86_64-linux";
  "artemis" = self.lib.mkHome "ashley.rose" "artemis" "aarch64-darwin";
}
