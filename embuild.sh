#!/bin/bash
set -euo pipefail

which emmake > /dev/null || (echo "you need to source emsdk_env.sh" && exit 1)

use_wasm=""
emflgs=""
emflgs+=" -s TOTAL_MEMORY=268435456"
emflgs+=" -s FORCE_FILESYSTEM=1"
if [ -z $use_wasm ]; then
emflgs+=" -s ASM_JS=1"
emflgs+=" -s WASM=0"
emflgs+=" -s BINARYEN_METHOD='asmjs'"
else
emflgs+=" -s WASM=1"
emflgs+=" -s BINARYEN_METHOD='native-wasm'"
fi


emenv_debug="y"
if [ -z $emenv_debug ]; then
emflgs+=" -O3 -g4"
else
emflgs+=" -O0 -g4"

# emflgs+=" -s UNALIGNED_MEMORY=1 " # not supported in fastcomp
# emflgs+=" -s SAFE_HEAP=1 "
# emflgs+=" -s SAFE_HEAP_LOG=1 "
emflgs+=" -s ASSERTIONS=2 " 
emflgs+=" -s DEMANGLE_SUPPORT=1"
fi

# emflgs+=" -s ERROR_ON_UNDEFINED_SYMBOLS=0"
emflgs+=" --js-library library_sdl.js"

export EMFLAGS=$emflgs

echo "emmake"
emmake make VERBOSE=1


echo "converting bitcode with flags '$EMFLAGS'"

cp ./Chocolate-Wolfenstein-3D ./Chocolate-Wolfenstein-3D.bc
emcc $emflgs ./Chocolate-Wolfenstein-3D.bc  -o ./Chocolate-Wolfenstein-3D.js \
    --preload-file audiohed.wl1 \
    --preload-file audiot.wl1 \
    --preload-file gamemaps.wl1 \
    --preload-file maphead.wl1 \
    --preload-file vgadict.wl1 \
    --preload-file vgagraph.wl1 \
    --preload-file vgahead.wl1 \
    --preload-file vswap.wl1 

echo "build Chocolate-Wolfenstein-3D.js with size $(stat -f '%z' ./Chocolate-Wolfenstein-3D.js)"
