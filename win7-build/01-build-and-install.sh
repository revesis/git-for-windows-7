#!/usr/bin/env bash
# Build Git 2.56.0 from source for Windows 7 (native mingw64), then install to a
# relocatable staging tree. Run with Git-for-Windows bash:
#   C:\Git\usr\bin\bash.exe -l win7-build/01-build-and-install.sh
set -o pipefail

# --- adjust these to your machine -------------------------------------------
GCC_BIN=/c/mingw64/bin          # winlibs GCC
DEPS=/c/3rd_part                # curl/openssl/pcre2/zlib/iconv/expat/gettext
GITTOOLS=/c/Git/usr/bin         # MSYS2 shell/make/perl from Git for Windows
SRC=/c/git-2.56.0.windows.4     # this source tree
STAGE=/c/stage256               # staging install dir (will be wiped)
# ----------------------------------------------------------------------------

export MSYSTEM=MINGW64
export PATH="$GCC_BIN:$DEPS/bin:$GITTOOLS:/usr/bin"
cd "$SRC" || { echo "source dir not found: $SRC"; exit 1; }

VARS=(CC=gcc
  "CFLAGS=-O2 -Wall -D_WIN32_WINNT=0x0601 -I$DEPS/include"
  "LDFLAGS=-L$DEPS/lib -L$GCC_BIN/../lib"
  NO_RUST=1                      # <-- the key: disable the Rust libgitcore
  USE_LIBPCRE2=YesPlease
  USE_GETTEXT_SCHEME=fallthrough
  "CURL_LDFLAGS=-lcurl"
  NO_TCLTK=1 NO_PYTHON=1
  RUNTIME_PREFIX=YesPlease       # locate helpers relative to git.exe -> relocatable
  prefix=/mingw64
)

echo "### make all"
make -j"$(nproc)" "${VARS[@]}" all || exit 1

echo "### make install -> $STAGE"
rm -rf "$STAGE"
make "${VARS[@]}" DESTDIR="$STAGE" install || exit 1

echo "### done: $STAGE/mingw64/bin/git.exe"
ls -la "$STAGE/mingw64/bin/git.exe"
