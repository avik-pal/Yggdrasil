# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "snappy"
version = v"1.2.1"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/google/snappy.git",
              "2c94e11145f0b7b184b831577c93e5a41c4c0346"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/snappy

cmake -B cmake-build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DBUILD_SHARED_LIBS=ON \
    -DSNAPPY_BUILD_BENCHMARKS=OFF \
    -DSNAPPY_BUILD_TESTS=OFF
cmake --build cmake-build --parallel ${nproc}
cmake --install cmake-build
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_cxxstring_abis(supported_platforms())

# The products that we will ensure are always built
products = [
    LibraryProduct("libsnappy", :libsnappy)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat = "1.6")
