# 在 Windows 7 上从源码构建 Git 2.56.0

Git for Windows 自 **2.47.0** 起不再支持 Windows 7/8——但这只是因为官方安装包捆绑的 **MSYS2 运行时升级到了 Cygwin 3.5**（`msys-2.0.dll` 不再能在 Win7 加载）。**用 mingw64 从源码编出来的原生 `git.exe` 与此无关，仍可在 Win7 上运行。**

实测：下列配方编出的 `git.exe` 在 `Windows 7 x64 (6.1.7601)` 上
`git version` / 本地 commit / **https clone** 全部正常。

## 唯一的关键改动

> Git 2.56 默认启用了用 Rust 写的 `libgitcore`（需要 `cargo`）。用 **`NO_RUST=1`** 关掉即可，编出纯 C 的 git。
> Makefile 自述：Rust 目前仍是可选项，到 **Git 3.0** 才会强制。

## 构建环境（本机实际使用）

| 组件 | 路径 | 说明 |
|---|---|---|
| shell / make / perl / msgfmt | `C:\Git\usr\bin` + `C:\3rd_part\bin` | Git for Windows 自带的 MSYS2 工具（Win7 兼容运行时） |
| C 编译器 | `C:\mingw64\bin` | winlibs GCC 15.2.0 |
| 依赖库/头文件 | `C:\3rd_part`（`include` / `lib` / `bin`） | curl / openssl / pcre2 / zlib / iconv / expat / gettext 等 |

> 路径按自己机器调整；脚本顶部有变量可改。

## 用法

```sh
# 1) 编译 + 安装到暂存目录（带 RUNTIME_PREFIX，产物可relocate）
C:\Git\usr\bin\bash.exe -l win7-build/01-build-and-install.sh

# 2) 组装可分发的便携目录（含全部运行时 DLL）
C:\Git\usr\bin\bash.exe -l win7-build/02-make-dist.sh
# 产物：C:\git-2.56.0-win7\  （解压即用）
```

## 运行时需要的非系统 DLL

原生 git 直接依赖（随 git.exe 一起分发）：

- `libpcre2-8-0.dll` `libiconv-2.dll` `libintl-8.dll` `libssp-0.dll` `libzlib.dll`

https 走 git 的 `LAZYLOAD_LIBCURL`——运行时 `LoadLibrary("libcurl-4.dll")`，需要一整套 curl 依赖；
直接复用 Git for Windows 自带的那套最省事（其 libcurl 用 **Schannel**，走 Windows 证书库，**无需 ca-bundle**）：

- `libcurl-4.dll` + `libpsl-5.dll` `libssh2-1.dll` `libnghttp2-14.dll`
  `libbrotlidec.dll` `libbrotlicommon.dll` `libidn2-0.dll` `libunistring-*.dll`
  `libzstd.dll` `zlib1.dll`

## 说明

- `git version --build-options` 里显示的 `libcurl 8.12.1` 是**编译时头文件版本**，运行时实际加载的是所提供的 `libcurl-4.dll`，功能不受影响。
- 关掉了 `tcltk`（git-gui/gitk）和 `python`，需要可自行开启。
- `-D_WIN32_WINNT=0x0601` 只是保险；实测不加也能在 Win7 加载，源码本身并无 Win8+ API 依赖。
