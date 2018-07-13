@echo off
cd %~dp0
if exist "build\" (
	echo "Deleting previous build directory..."
	@RD /S /Q "build"
)
call vcvars64.bat
cmake %~dp0 -G "Ninja" -Bbuild -DCMAKE_C_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_CXX_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_LINKER="%MAKEKIT_LLVM_BIN%/lld-link.exe"
set /p dummy=Press any button:
@echo on
