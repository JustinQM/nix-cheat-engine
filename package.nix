{
  lib,
  stdenv,
  fetchzip,
  qt6,
  libX11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  libGL,          # 1. Added libGL to inputs
  glib,
  zlib,
  gcc-unwrapped,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
}:

let
  version = "7.7";

  bundle = fetchzip {
    url = "https://cheatengine.org/download/CheatEngineLinux77.zip";
    hash = "sha256-6eYwxx/vGqoJdzz3nQVTB7GjsEb0zOG861y9YbkLxe8=";
    stripRoot = false;
  };

  desktopItem = makeDesktopItem {
    name = "cheat-engine";
    desktopName = "Cheat Engine";
    exec = "cheat-engine";
    icon = "cheat-engine";
    type = "Application";
    categories = [ "Utility" "Development" ];
    terminal = false;
  };

in
stdenv.mkDerivation {
  pname = "cheat-engine";
  inherit version;

  src = bundle;

  nativeBuildInputs = [
    autoPatchelfHook
    qt6.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    libX11
    libxcb
    libxcursor
    libxi
    libxrandr
    libGL          # 2. Added libGL here so it's available during build/patching
    glib
    zlib
    gcc-unwrapped.lib
  ];

  # 3. Forces autoPatchelfHook to bake libGL into the binary's runtime search path (RPATH)
  runtimeDependencies = [
    libGL
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/cheat-engine

    # Check for flat vs nested structure safely without triggering nullglob bugs
    if [ -f cheatengine-x86_64 ]; then
      echo "Detected flat directory structure."
      cp -r * $out/share/cheat-engine/
    else
      # Safely evaluate wildcards into an array to prevent missing operand errors
      nested_bin=( CheatEngineLinux*/cheatengine-x86_64 )
      if [ ''${#nested_bin[@]} -gt 0 ]; then
        echo "Detected nested CheatEngineLinux directory structure."
        cp -r CheatEngineLinux*/* $out/share/cheat-engine/
      else
        echo "Error: Could not locate cheatengine-x86_64 in the source tree."
        ls -la
        exit 1
      fi
    fi

    chmod +x $out/share/cheat-engine/cheatengine-x86_64

    # Icon installation
    mkdir -p $out/share/icons/hicolor/256x256/apps
    if [ -f cheatengine.png ]; then
      cp cheatengine.png $out/share/icons/hicolor/256x256/apps/cheat-engine.png
    else
      nested_icon=( CheatEngineLinux*/cheatengine.png )
      if [ ''${#nested_icon[@]} -gt 0 ]; then
        cp "''${nested_icon[0]}" $out/share/icons/hicolor/256x256/apps/cheat-engine.png
      fi
    fi

    # Desktop entry installation
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/

    runHook postInstall
  '';

  postFixup = ''
    # Manually invoke wrapQtApp since the binary lives in share/ instead of bin/
    wrapQtApp $out/share/cheat-engine/cheatengine-x86_64

    # Create an executable wrapper in bin/ so it maps to the desktop shortcut and system PATH
    mkdir -p $out/bin
    makeWrapper $out/share/cheat-engine/cheatengine-x86_64 $out/bin/cheat-engine
  '';

  meta = {
    description = "Cheat Engine - memory scanner and debugger";
    homepage = "https://cheatengine.org";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
