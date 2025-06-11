{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  gtk3,
  zlib,
  dbus,
  hidapi,
  libGL,
  libXcursor,
  libXext,
  libXi,
  libXinerama,
  libxkbcommon,
  libXrandr,
  libXScrnSaver,
  libXxf86vm,
  udev,
  vulkan-loader,
  wayland,
}:

let
  pname = "my-dystopian-robot-girlfriend";
  version = "0.90.15";
  execName = "\"My Dystopian Robot Girlfriend.x86_64\"";
in

stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchzip {
    url = "https://github.com/eidoid/flake-binary-release-download/releases/download/MDRG/factorial-omega-linux-64.zip";
    sha256 = "sha256-fSgmQgyR9Qp0XYX9p3v1W62DuUrs/RiCjciNCW9TL48=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    # Load-time libraries (loaded from DT_NEEDED section in ELF binary)
    alsa-lib
    gtk3
    stdenv.cc.cc.lib
    zlib
    # Run-time libraries (loaded with dlopen)
    dbus
    hidapi
    libGL
    libXcursor
    libXext
    libXi
    libXinerama
    libxkbcommon
    libXrandr
    libXScrnSaver
    libXxf86vm
    udev
    vulkan-loader
    wayland
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname}
    cp -r . $out/share/${pname}

    makeWrapper $out/share/${pname}/${execName} $out/bin/${pname} \
      --chdir "$out/share/${pname}"

    runHook postInstall
  '';
  postFixup = ''
    patchelf \
      --add-needed libpthread.so.0 \
      --add-needed libasound.so.2 \
      --add-needed libdbus-1.so.3 \
      --add-needed libGL.so.1 \
      --add-needed libhidapi-hidraw.so.0 \
      --add-needed libudev.so.1 \
      --add-needed libvulkan.so.1 \
      --add-needed libwayland-client.so.0 \
      --add-needed libwayland-cursor.so.0 \
      --add-needed libwayland-egl.so.1 \
      --add-needed libX11.so.6 \
      --add-needed libXcursor.so.1 \
      --add-needed libXext.so.6 \
      --add-needed libXi.so.6 \
      --add-needed libXinerama.so.1 \
      --add-needed libxkbcommon.so.0 \
      --add-needed libXrandr.so.2 \
      --add-needed libXss.so.1 \
      --add-needed libXxf86vm.so.1 \
      "$out/share/${pname}/UnityPlayer.so"
  '';

  meta = with lib; {
    description = "My Dystopian Robot Grilfriend Game";
    mainProgram = "${pname}";
    homepage = "https://incontinentcell.itch.io/factorial-omega";
    changelog = "https://incontinentcell.itch.io/factorial-omega/devlog/884412/09015-update-released";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ eidoid ];
  };
}
