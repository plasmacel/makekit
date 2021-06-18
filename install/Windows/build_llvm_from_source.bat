@echo off
set DEFAULT_LLVM_DIR=%ProgramFiles%\LLVM
set MK_LLVM_BRANCH=trunk

set /p MK_LLVM_VER=LLVM version to install (without dots):
if "%MK_LLVM_VER%" == "" (
	set MK_LLVM_BRANCH=trunk
) else (
	set MK_LLVM_BRANCH=branches/release_%MK_LLVM_VER%
)

set /p MK_LLVM_INSTALL_DIR=LLVM installation directory (default is %DEFAULT_LLVM_DIR%):
if "%MK_LLVM_INSTALL_DIR%" == "" (
	set MK_LLVM_INSTALL_DIR=%DEFAULT_LLVM_DIR%
)
if exist "%MK_LLVM_INSTALL_DIR%" (
	echo ERROR: LLVM is already installed. Removing previous vesion...
	rd /s /q "%MK_LLVM_INSTALL_DIR%"
) else (
	mkdir %MK_LLVM_INSTALL_DIR%
)

:: LLVM
cd %MK_LLVM_INSTALL_DIR%
svn co http://llvm.org/svn/llvm-project/llvm/%MK_LLVM_BRANCH% llvm

:: Compiler-RT
cd %MK_LLVM_INSTALL_DIR%
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/compiler-rt/%MK_LLVM_BRANCH% compiler-rt

:: OpenMP
cd %MK_LLVM_INSTALL_DIR%
cd llvm/projects
svn co http://llvm.org/svn/llvm-project/openmp/%MK_LLVM_BRANCH% openmp

:: clang
cd %MK_LLVM_INSTALL_DIR%
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/cfe/%MK_LLVM_BRANCH% clang

:: clang-tools-extra
cd %MK_LLVM_INSTALL_DIR%
cd llvm/tools/clang/tools
svn co http://llvm.org/svn/llvm-project/clang-tools-extra/%MK_LLVM_BRANCH% extra

:: LLD
cd %MK_LLVM_INSTALL_DIR%
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/lld/%MK_LLVM_BRANCH% lld

:: Polly Loop Optimizer
cd %MK_LLVM_INSTALL_DIR%
cd llvm/tools
svn co http://llvm.org/svn/llvm-project/polly/%MK_LLVM_BRANCH% polly

:: libc++ and libc++abi
:: cd %MK_LLVM_INSTALL_DIR%
:: cd llvm/projects
:: svn co http://llvm.org/svn/llvm-project/libcxx/%MK_LLVM_BRANCH% libcxx
:: svn co http://llvm.org/svn/llvm-project/libcxxabi/%MK_LLVM_BRANCH% libcxxabi

:: Test Suite
:: cd %MK_LLVM_INSTALL_DIR%
:: cd llvm/projects
:: svn co http://llvm.org/svn/llvm-project/test-suite/%MK_LLVM_BRANCH% test-suite

:: Build LLVM

cd %MK_LLVM_INSTALL_DIR%
mkdir build
call vsdevcmd.bat -arch=x64 -host_arch=x64
cmake llvm -Bbuild -GNinja -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_LINKER=lld-link -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=directory -DLIBOMP_ARCH=x86_64 -DLIBOMP_CXXFLAGS=/D_GNU_SOURCE -DLLVM_ENABLE_ASSERTIONS=OFF -DLIBOMP_HAVE_WEAK_ATTRIBUTE=FALSE
ninja -C build

:: /usr/local
:: %ProgramFiles%/LLVM

exit /b %ERRORLEVEL%
