echo "Hello World!"
cmake . -G "Ninja" -Bbuild -DCMAKE_C_COMPILER="clang" -DCMAKE_CXX_COMPILER="clang" -DCMAKE_LINKER="lld-link"
