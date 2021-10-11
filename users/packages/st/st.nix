{ st, harfbuzz, writeText, fetchpatch, ... }:

# Personal fork of ST
(st.overrideAttrs ( oa: rec { 

  # Config file
  configFile = writeText "config.def.h" (builtins.readFile ./config.h);
  postPatch = "${oa.postPatch}\n cp ${configFile} config.def.h";

  # Dependencies
  buildInputs = oa.buildInputs ++ [ harfbuzz ];

  # Patches
  patches = [

    # Ligatures
    (fetchpatch {
      url = "https://st.suckless.org/patches/ligatures/0.8.3/st-ligatures-20200430-0.8.3.diff";
      sha256 = "18fllssg5d5gik1x0ppz232vdphr0y2j5z8lhs5j9zjs8m9ria5w";
    })
  
  ];
}))
