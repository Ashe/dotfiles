{ st, harfbuzz, writeText, fetchpatch, theme, ... }:

# Personal fork of ST
(st.overrideAttrs ( oa: rec {

  # Config file
  configData = builtins.replaceStrings
      (builtins.attrNames theme.colourscheme)
      (builtins.attrValues theme.colourscheme)
      (builtins.readFile ./config.h);
  configFile = writeText "config.def.h" configData;
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

    # Undercurls
    (fetchpatch {
      url = "https://st.suckless.org/patches/undercurl/st-undercurl-0.8.4-20210822.diff";
      sha256 = "sha256-sPsm4cVhoIweYYjOlJ3QLqS3DyjwwwK+SUKJw28bNO0";
    })

  ];
}))
