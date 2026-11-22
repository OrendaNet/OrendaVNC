param(
    [Parameter(Mandatory)] [string] $VcpkgRoot,
    [string] $DependencyDirectory = (Join-Path $PSScriptRoot 'vcpkg_installed'),
    [string] $OutputDirectory = (Join-Path $PSScriptRoot 'x64')
)
$ErrorActionPreference = 'Stop'
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$msbuild = & $vswhere -latest -products '*' -requires Microsoft.Component.MSBuild -find 'MSBuild\Current\Bin\MSBuild.exe' | Select-Object -First 1
if (!$msbuild) { throw 'Install Visual Studio 2022 with the C++ desktop workload.' }
& git -C $PSScriptRoot submodule update --init --recursive
if ($LASTEXITCODE) { throw 'Could not retrieve the pinned UltraVNC web resources.' }
& (Join-Path $VcpkgRoot 'vcpkg.exe') install --triplet x64-windows-static "--x-manifest-root=$PSScriptRoot" "--x-install-root=$DependencyDirectory"
if ($LASTEXITCODE) { throw 'Could not build the pinned VNC dependencies.' }
$triplet = Join-Path $DependencyDirectory 'x64-windows-static'
$previousCL = $env:CL
$previousLink = $env:LINK
try {
    $env:CL = '/I"' + $triplet + '\include"'
    $libraries = Get-ChildItem (Join-Path $triplet 'lib') -Filter '*.lib'
    $env:LINK = '/LIBPATH:"' + $triplet + '\lib" ' + (($libraries | ForEach-Object { '/DEFAULTLIB:' + $_.Name }) -join ' ')
    New-Item -ItemType Directory -Force (Join-Path $PSScriptRoot 'winvnc\x64\Release') | Out-Null
    foreach ($project in 'winvnc\winvnc\winvnc.vcxproj','winvnc\vnchooks\vnchooks.vcxproj') {
        & $msbuild (Join-Path $PSScriptRoot $project) /m:3 /nologo /p:Configuration=Release /p:Platform=x64 /p:PlatformToolset=v143 /p:PreBuildEventUseInBuild=false /p:PostBuildEventUseInBuild=false /p:VcpkgEnabled=false
        if ($LASTEXITCODE) { throw "Build failed for $project" }
    }
} finally { $env:CL = $previousCL; $env:LINK = $previousLink }
$package = Join-Path $OutputDirectory 'OrendaVNC-win64'
New-Item -ItemType Directory -Force -Path $package | Out-Null
foreach ($name in 'winvnc.exe','vnchooks.dll') {
    $binary = Get-ChildItem (Join-Path $PSScriptRoot 'winvnc') -Filter $name -Recurse | Where-Object FullName -match '\\x64\\Release\\' | Select-Object -First 1
    if (!$binary) { throw "Could not find $name in x64 Release output." }
    Copy-Item -LiteralPath $binary.FullName -Destination $package
}
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'LICENSE'), (Join-Path $PSScriptRoot 'ORENDA.md'), (Join-Path $PSScriptRoot '3rdparty\noVNC\LICENSE.txt') -Destination $package
New-Item -ItemType File -Force (Join-Path $package 'ultravnc.portable') | Out-Null
foreach ($license in Get-ChildItem (Join-Path $triplet 'share') -Filter copyright -Recurse) {
    Copy-Item -LiteralPath $license.FullName -Destination (Join-Path $package ($license.Directory.Name + '-LICENSE.txt'))
}
Compress-Archive -LiteralPath $package -DestinationPath (Join-Path $OutputDirectory 'OrendaVNC-win64.zip') -Force
