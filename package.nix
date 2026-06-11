{ lib
, stdenv
, fetchzip
, buildFHSEnv
, qt6
, libX11
, libxcb
, xorg
, gcc-unwrapped
, glib
, zlib
, makeWrapper
}:

let
  version = "7.7";

  bundle = fetchzip {
    url = "https://cheatengine.org/download/CheatEngineLinux77.zip";
    # populated by update.sh
    hash = "sha256-6eYwxx/vGqoJdzz3nQVTB7GjsEb0zOG861y9YbkLxe8=";
    stripRoot = false;
  };

  # Inner derivation: just unpacks and installs the bundle as-is
  ce-unwrapped = stdenv.mkDerivation {
    pname = "cheat-engine-unwrapped";
    inherit version;
    src = bundle;

    installPhase = ''
      mkdir -p $out/share/cheat-engine
      cp -r . $out/share/cheat-engine/
      chmod +x $out/share/cheat-engine/cheatengine-x86_64
    '';

    meta.platforms = [ "x86_64-linux" ];
  };

in buildFHSEnv {
  name = "cheat-engine";

  targetPkgs = pkgs: with pkgs; [
    qt6.qtbase
    qt6.qtwayland
    libX11
    libxcb
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    gcc-unwrapped.lib   # libstdc++.so.6
    glib
    zlib
  ];

  runScript = ''
    cd ${ce-unwrapped}/share/cheat-engine
    exec ./cheatengine-x86_64 "$@"
  '';

  meta = {
    description = "Cheat Engine - memory scanner and debugger";
    homepage = "https://cheatengine.org";
    platforms = [ "x86_64-linux" ];
    # CE is freeware, not open source
    license = lib.licenses.unfree;
  };
}
