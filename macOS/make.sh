BUILD_TYPE=""

if [ $1 == "debug" ]; then
	BUILD_TYPE="Debug"
elif [ $1 == "debuginfo" ]; then
	BUILD_TYPE="RelWithDebInfo"
elif [ $1 == "release" ]; then
	BUILD_TYPE="Release"
fi

[ -d build ] && rmdir build
cmake . -G "Ninja" -Bbuild -DCMAKE_C_COMPILER="clang" -DCMAKE_CXX_COMPILER="clang" -DCMAKE_LINKER="lld-link" -DCMAKE_BUILD_TYPE=$BUILD_TYPE
