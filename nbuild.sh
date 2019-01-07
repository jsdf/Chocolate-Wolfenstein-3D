#!/bin/bash
set -euo pipefail
rsync -aHE  ./*.cpp ../wolfnbuild/
rsync -aHE  ./*.h ../wolfnbuild/
cd ../wolfnbuild/
make
./Chocolate-Wolfenstein-3D