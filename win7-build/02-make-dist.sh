#!/usr/bin/env bash
# Assemble a self-contained, portable Git for Windows 7 directory from the
# staging tree produced by 01-build-and-install.sh, bundling every runtime DLL.
#   C:\Git\usr\bin\bash.exe -l win7-build/02-make-dist.sh
set -e

# --- adjust these to your machine -------------------------------------------
STAGE=/c/stage256               # from 01-build-and-install.sh
DIST=/c/git-2.56.0-win7         # output (will be wiped)
GCC_BIN=/c/mingw64/bin
DEPS=/c/3rd_part
GFW=/c/Git/mingw64/bin          # Git-for-Windows bin: source of the curl stack
# ----------------------------------------------------------------------------

rm -rf "$DIST"; mkdir -p "$DIST"
cp -a "$STAGE/mingw64/." "$DIST"/

# curl stack (Schannel libcurl + its deps) reused from Git for Windows
CURL_SET="libcurl-4.dll libbrotlidec.dll libbrotlicommon.dll libidn2-0.dll
libiconv-2.dll libintl-8.dll libunistring-5.dll libpsl-5.dll libssh2-1.dll
zlib1.dll libzstd.dll libpcre2-8-0.dll"

# put all runtime DLLs in both bin/ and libexec/git-core/ so helpers always load
for sub in bin libexec/git-core; do
  for d in $CURL_SET; do cp -f "$GFW/$d" "$DIST/$sub/"; done
  cp -f "$GCC_BIN/libssp-0.dll" "$DIST/$sub/"
  cp -f "$DEPS/bin/libzlib.dll" "$DIST/$sub/"
done

echo "### dist ready: $DIST"
du -sh "$DIST"
echo "bin DLLs: $(ls "$DIST"/bin/*.dll | wc -l)"
