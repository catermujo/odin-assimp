@echo off

setlocal EnableDelayedExpansion

if not exist assimp\NUL (
	git clone https://github.com/assimp/assimp --depth=1
)

set binaries_dir=build

echo Configuring build...
cmake -S assimp -B %binaries_dir% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DASSIMP_BUILD_TESTS=OFF -DASSIMP_INSTALL=OFF -DASSIMP_INSTALL_PDB=OFF -DUSE_STATIC_CRT=ON -DASSIMP_BUILD_USD_IMPORTER=ON -DASSIMP_WARNINGS_AS_ERRORS=OFF

echo Building project...
cmake --build %binaries_dir% --config Release

copy /y build\windows\lib\Release\assimp-vc143-mt.lib assimp.lib

popd bindgen

echo "Build completed successfully!"
