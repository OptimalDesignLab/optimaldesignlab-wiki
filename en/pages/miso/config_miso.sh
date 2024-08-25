cmake .. \
 -DCMAKE_C_COMPILER="mpicc" \
 -DCMAKE_CXX_COMPILER="mpicxx" \
 -DCMAKE_BUILD_TYPE=Release \
 -DAdept_ROOT="$PWD/../../adept-install" \
 -DMFEM_DIR="$PWD/../../mfem/build" \
 -DPUMI_DIR="$PWD/../../core/build/install/" \
 -DBUILD_SHARED_LIBS="OFF" \
 -DBUILD_TESTING="ON" \
 -DBUILD_PYTHON_WRAPPER="ON" \
 -DMISO_USE_CLANG_TIDY="OFF" \
 -DCMAKE_EXPORT_COMPILE_COMMANDS="ON" \
# -DCMAKE_INSTALL_PREFIX="$PWD/.." \
