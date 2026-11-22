# OrendaVNC for Windows

This optional build of UltraVNC 1.8.3.3 accepts local RFB connections on port 5900 by default. OrendaConnect provides the private organization connection. The separate HTTP listener and file transfer are disabled by default.

Extract the zip into a writable directory and start `winvnc.exe`. Set a VNC password in the server properties. In OrendaConnect, open **Manage apps → This computer → New Internal App → Remote desktop (VNC)**. Enter `127.0.0.1`, port `5900`, and the same password. Ending the viewer session leaves the server running. The included portable marker keeps the configuration in the extracted folder.

Build on Windows x64 using Visual Studio 2022 with the C++ desktop workload, Git, NASM, and a bootstrapped Microsoft vcpkg checkout with its version history. Run `.\build-orenda.ps1 -VcpkgRoot C:\path\to\vcpkg`. The script packages the server, keyboard/mouse hook library, portable marker and license notices under `x64`.

The corresponding source, build script and pinned dependency manifest are at [OrendaNet/OrendaVNC](https://github.com/OrendaNet/OrendaVNC/tree/orenda).
