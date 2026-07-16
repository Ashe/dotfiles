{ self, ... }:
{
  lab = self.lib.mkSystem "lab";
  tomoe = self.lib.mkSystem "tomoe";
}
