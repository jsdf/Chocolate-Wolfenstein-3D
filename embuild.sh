#!/bin/bash
set -euo pipefail

which emmake > /dev/null || (echo "you need to source emsdk_env.sh" && exit 1)

emenv_emterpreter="y"
emenv_debug=""
emenv_release="y"
use_wasm="y"
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


if [ -n "$emenv_emterpreter" ]; then
  emflgs+=" -O3"
  emflgs+=" -s EMTERPRETIFY=1"
  emflgs+=" -s EMTERPRETIFY_ASYNC=1"
  emflgs+=" -s EMTERPRETIFY_WHITELIST=$(node ./whitelist-funcs.js)"

  if [ -z "$emenv_release" ]; then
    # for finding functions to whitelist
    emflgs+=" -s ASSERTIONS=1 --profiling-funcs"
  fi
else
  if [ -n "$emenv_release" ]; then
    emflgs+=" -O3"
  else
    if [ -n "$emenv_debug" ]; then
      emflgs+=" -O0 -g4"

      # emflgs+=" -s UNALIGNED_MEMORY=1 " # not supported in fastcomp
      # emflgs+=" -s SAFE_HEAP=1 " # for memory corruption debugging, v slow
      # emflgs+=" -s SAFE_HEAP_LOG=1 " # see above
      emflgs+=" -s ASSERTIONS=2 " 
      emflgs+=" -s DEMANGLE_SUPPORT=1"
    else
      # default dev build: opt but with symbols
      emflgs+=" -O3 -g4"
    fi
  fi
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
