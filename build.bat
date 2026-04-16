@echo off

setlocal EnableDelayedExpansion

if not exist assimp (
	git clone --revision 95f09deaaed342b5f4ac6aa0eb5ad747c476f78b https://github.com/assimp/assimp --depth=1 || exit /b 1
)

set binaries_dir=build

echo Configuring build...
cmake -S assimp -B %binaries_dir% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DASSIMP_BUILD_TESTS=OFF -DASSIMP_INSTALL=OFF -DASSIMP_INSTALL_PDB=OFF -DUSE_STATIC_CRT=ON -DASSIMP_BUILD_USD_IMPORTER=ON -DASSIMP_WARNINGS_AS_ERRORS=OFF || exit /b 1

echo Building project...
cmake --build %binaries_dir% --config Release || exit /b 1

if not exist "%binaries_dir%\lib\Release\assimp-*.lib" (
    echo ERROR: Could not find the assimp Windows library in %binaries_dir%\lib\Release.
    exit /b 1
)
for %%F in ("%binaries_dir%\lib\Release\assimp-*.lib") do set "ASSIMP_LIB=%%~fF"

REM DUMBAI: Publish the Windows artifact under the filename the Odin bindings import.
copy /y "%ASSIMP_LIB%" libassimp.lib >nul || exit /b 1

echo Build completed successfully!
