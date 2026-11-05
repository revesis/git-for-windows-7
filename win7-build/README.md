# Building Git 2.56.0 from source for Windows 7

Git for Windows dropped Windows 7/8 support starting with **2.47.0** — but only
because the bundled **MSYS2 runtime moved to Cygwin 3.5**, whose `msys-2.0.dll`
no longer loads on Windows 7. **The native `git.exe` compiled from source with
mingw64 is unaffected and still runs on Windows 7.**

Verified: the `git.exe` produced by this recipe runs on `Windows 7 x64
(6.1.7601)` — `git version`, local commits and **https clone** all work.

## The one change that matters

> Git 2.56 enables a Rust component (`libgitcore`) by default, which needs `cargo`.
> Disable it with **`NO_RUST=1`** to get a pure-C build.
> Per the Makefile, Rust is still optional for now and only becomes mandatory in **Git 3.0**.

## Build environment (as used on this machine)

| Component | Path | Notes |
|---|---|---|
| shell / make / perl / msgfmt | `C:\Git\usr\bin` + `C:\3rd_part\bin` | MSYS2 tools from Git for Windows (Win7-compatible runtime) |
| C compiler | `C:\mingw64\bin` | winlibs GCC 15.2.0 |
| dependency libs / headers | `C:\3rd_part` (`include` / `lib` / `bin`) | curl / openssl / pcre2 / zlib / iconv / expat / gettext, etc. |

> Adjust paths to your machine; the scripts expose them as variables at the top.

## Usage

```sh
# 1) Compile + install into a staging dir (RUNTIME_PREFIX -> relocatable output)
C:\Git\usr\bin\bash.exe -l win7-build/01-build-and-install.sh

# 2) Assemble a self-contained portable directory (bundles every runtime DLL)
C:\Git\usr\bin\bash.exe -l win7-build/02-make-dist.sh
# output: C:\git-2.56.0-win7\  (unzip and run)
```

## Runtime DLLs (non-system)

Direct dependencies of the native git (ship alongside `git.exe`):

- `libpcre2-8-0.dll` `libiconv-2.dll` `libintl-8.dll` `libssp-0.dll` `libzlib.dll`

https goes through git's `LAZYLOAD_LIBCURL` — at runtime it does
`LoadLibrary("libcurl-4.dll")`, which needs the full curl dependency chain.
The simplest source is the set shipped with Git for Windows (its libcurl uses
**Schannel**, so it reads the Windows certificate store and needs **no ca-bundle**):

- `libcurl-4.dll` + `libpsl-5.dll` `libssh2-1.dll` `libnghttp2-14.dll`
  `libbrotlidec.dll` `libbrotlicommon.dll` `libidn2-0.dll` `libunistring-*.dll`
  `libzstd.dll` `zlib1.dll`

## Notes

- `git version --build-options` reports `libcurl 8.12.1` — that is the
  **compile-time header version**; at runtime the provided `libcurl-4.dll` is
  what's actually loaded, with no effect on functionality.
- `tcltk` (git-gui/gitk) and `python` are disabled; enable them if you need them.
- `-D_WIN32_WINNT=0x0601` is just insurance; the binary loads on Windows 7 even
  without it — the source itself has no Windows 8+ API dependency.
