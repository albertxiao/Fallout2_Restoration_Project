#!/bin/bash

set -xeu -o pipefail

# release?
if [ -n "$TRAVIS_TAG" ]; then # tag found: releasing
  version="$TRAVIS_TAG"

  # data
  dat="$mod_name.dat"
  mkdir -p "$mods_dir"
  chmod 0444 data/proto/*/*

  cd data
  # I don't know how to pack recursively
  for f in $(find . -type f | sed -e 's|^\.\/||' -e 's|\/|\\|g' | sort); do # replace slashes with backslashes
    WINEARCH=win32 WINEDEBUG=-all wine "$bin_dir/dat2.exe" a $dat "$f"
  done
  cd ..
  mv "data/$dat" "$mods_dir/"

  # sfall
  sfall_url="https://sourceforge.net/projects/sfall/files/sfall/sfall_$sfall_version.7z/download"
  wget -q "$sfall_url" -O sfall.7z
  7z e sfall.7z ddraw.dll
  cp extra/sfall/ddraw.ini .
  zip -r "${mod_name}_${version}.zip" ddraw.dll ddraw.ini "$mods_dir/" # our package
fi
