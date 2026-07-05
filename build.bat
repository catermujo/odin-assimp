@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"

if not exist assimp (
	git clone --revision 95f09deaaed342b5f4ac6aa0eb5ad747c476f78b https://github.com/assimp/assimp --depth=1
)

set binaries_dir=build
set output_dir=windows_%VENDOR_WINDOWS_ARCH%

echo Configuring build...
cmake -S assimp -B %binaries_dir% -A %VENDOR_WINDOWS_ARCH% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DASSIMP_BUILD_TESTS=OFF -DASSIMP_INSTALL=OFF -DASSIMP_INSTALL_PDB=OFF -DUSE_STATIC_CRT=ON -DASSIMP_BUILD_USD_IMPORTER=ON -DASSIMP_WARNINGS_AS_ERRORS=OFF || exit /b 1

echo Building project...
cmake --build %binaries_dir% --config Release || exit /b 1

set ASSIMP_LIB=
for %%F in (
    build\windows\lib\Release\assimp-vc143-mt.lib
    build\lib\Release\assimp-vc143-mt.lib
    build\Release\assimp-vc143-mt.lib
    build\windows\lib\Release\assimp-vc*.lib
    build\lib\Release\assimp-vc*.lib
    build\Release\assimp-vc*.lib
) do (
    if not defined ASSIMP_LIB if exist %%F set ASSIMP_LIB=%%F
)

if not defined ASSIMP_LIB (
    echo ERROR: Could not find built assimp static library
    exit /b 1
)

if not exist %output_dir% mkdir %output_dir%
copy /y %ASSIMP_LIB% %output_dir%\libassimp.lib >nul || exit /b 1

echo Build completed successfully!
