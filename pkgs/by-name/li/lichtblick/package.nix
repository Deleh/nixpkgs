{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, alsa-lib
, dpkg
, gtk3
, mesa
, nss
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lichtblick";
  version = "1.24.3";

  src = if stdenv.isAarch64 then fetchurl {
    url = "https://github.com/Lichtblick-Suite/lichtblick/releases/download/v${finalAttrs.version}/lichtblick-${finalAttrs.version}-linux-arm64.deb";
    sha256 = "sha256-tgimlPHaJGBtxsiJWlOSOQTbYs2HnL2MVKrpLMkfZhA=";
  } else fetchurl {
    url = "https://github.com/Lichtblick-Suite/lichtblick/releases/download/v${finalAttrs.version}/lichtblick-${finalAttrs.version}-linux-amd64.deb";
    sha256 = "sha256-wgqqAG/Uj6qjBL1LJcR5oSfNMFUWIfavCA1Wdvk4bjw=";
  };

  unpackPhase = ''
    ${dpkg}/bin/dpkg -x $src .
  '';

  buildInputs = [
    alsa-lib
    gtk3
    mesa
    nss
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp -R usr/share opt $out/
    substituteInPlace $out/share/applications/lichtblick.desktop \
      --replace /opt/ $out/opt/

    ln -s $out/opt/Lichtblick/lichtblick $out/bin/lichtblick

    runHook postInstall
  '';

  preFixup = ''
    patchelf --add-needed libEGL.so.1 $out/bin/lichtblick
  '';
})
