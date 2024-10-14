{ appimagefile, nixpkgs' ? <nixpkgs> }:

# nix build -f test-appimage.nix --arg appimagefile ./VLC*AppImage

with import nixpkgs' {};

runCommand "patchelf" {} ''
  cp ${appimagefile} $out
  chmod +w $out
  patchelf \
    --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
    --set-rpath ${lib.makeLibraryPath [ stdenv.cc.libc fuse zlib glib ]}
    $out
''
