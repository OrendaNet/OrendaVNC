# OrendaVNC for Windows

This optional build of UltraVNC 1.8.3.3 accepts local RFB connections on port 5900 by default. OrendaConnect provides the private organization connection. The separate HTTP listener and file transfer are disabled by default.

OrendaConnect starts its bundled copy for an authorized desktop session. The managed profile requests 60 fps. For capture rates above 30 fps this fork also applies the configured interval to GDI polling and the desktop update thread. Cursor shapes travel separately from the framebuffer.

For a standalone server, extract the zip into a writable directory and start `winvnc.exe`. Set a VNC password in the server properties. In OrendaConnect choose **Remote desktop → Desktop source → Enter server address** and enter `127.0.0.1`, port `5900`, and that password. Ending the viewer session leaves a separately started server running.

Build on Windows x64 using Visual Studio 2022 with the C++ desktop workload, Git, NASM, and a bootstrapped Microsoft vcpkg checkout with its version history. Run `.\build-orenda.ps1 -VcpkgRoot C:\path\to\vcpkg`. The script packages the server, keyboard/mouse hook library, portable marker and license notices under `x64`.

The corresponding source, build script and pinned dependency manifest are at [OrendaNet/OrendaVNC](https://github.com/OrendaNet/OrendaVNC/tree/orenda).
