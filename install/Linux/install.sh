#!/bin/bash
if ! [ "$0" == "bash" ] ; then
    echo "Usage:"
    echo "  source ${BASH_SOURCE[0]}"
    exit 1
fi

# Find the path to the root of makekit
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd | xargs dirname | xargs dirname)

echo "Detecting Operating System type..."

# Set package manager based on OS type
if [ -f /etc/redhat-release ] ; then
    echo "ERROR: RedHat is not supported"
    # TODO: yum
    exit 1
elif [ -f /etc/arch-release ] ; then
    echo "ERROR: Arch is not supported"
    # TODO: pacman
    exit 1
elif [ -f /etc/gentoo-release ] ; then
    echo "ERROR: Gentoo is not supported"
    # TODO: emerge
    exit 1
elif [ -f /etc/SuSe-release ] ; then
    echo "ERROR: SuSe is not supported"
    # TODO: zypp
    exit 1
elif [ -f /etc/debian_version ] ; then
    DIST=`cat /etc/lsb-release | grep -Po "CODENAME=\K.+"`
    PACKAGE_MANAGER=apt-get
    echo "Debian found: '${DIST}'"
else
    echo "ERROR: Unknown distribution"
    exit 1
fi

echo "Detecting CMake..."

if ! [ -x "$(command -v cmake)" ] ; then
    # Install CMake
    echo "CMake not found, installing via package manager..."
    sudo ${PACKAGE_MANAGER} install -y --allow-unauthenticated cmake
else
    # Print CMake version
    echo "CMake found, version: "`cmake --version | grep -Po "version \K[0-9]+.[0-9]+.*"`
fi

echo "Detecting Ninja..."

if ! [ -x "$(command -v ninja)" ] ; then
    # Install Ninja
    echo "Ninja not found, installing via package manager..."
    sudo ${PACKAGE_MANAGER} install -y --allow-unauthenticated ninja-build
else
    # Print Ninja version
    echo "Ninja found, version: "`ninja --version`
fi

echo "Detecting LLVM..."

if ! [ -x "$(command -v clang)" ] ; then
    # Install LLVM
    echo "LLVM not found, installing..."
    CLANG_VERSION=""
else
    # Update LLVM to latest
    CLANG_VERSION=`clang --version | grep -Po "version \K[0-9]+.[0-9]+"`
    echo "LLVM version ${CLANG_VERSION} found, trying to update to latest"
fi

CLANG_LATEST_VERSION=`wget -O - http://apt.llvm.org/${DIST}/dists/ 2>/dev/null | gunzip -c 2>/dev/null | grep -Po "${DIST}-\K[0-9]+.[0-9]+" | sort | tail -n 1`

if [ "${CLANG_LATEST_VERSION}" == "" ] ; then
    CLANG_LATEST_VERSION=`wget -O - http://apt.llvm.org/${DIST}/dists/ 2>/dev/null | grep -Po "${DIST}-\K[0-9]+.[0-9]+" | sort | tail -n 1`
fi

if [ "${CLANG_LATEST_VERSION}" == "" ] ; then
    echo "WARNING: Could not request latest LLVM version from 'http://apt.llvm.org' for ${DIST}"
    echo "         Latest LLVM is not being istalled!"
else
    if ! [ "${CLANG_VERSION}" == "${CLANG_LATEST_VERSION}" ] ; then
        echo "Installing LLVM ${CLANG_LATEST_VERSION}..."
        sudo apt-add-repository "deb http://apt.llvm.org/${DIST}/ llvm-toolchain-${DIST}-${CLANG_LATEST_VERSION} main"
        sudo ${PACKAGE_MANAGER} update
        sudo ${PACKAGE_MANAGER} install -y --allow-unauthenticated clang-${CLANG_LATEST_VERSION} lldb-${CLANG_LATEST_VERSION} lld-${CLANG_LATEST_VERSION}
        sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${CLANG_LATEST_VERSION} 1000
        sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${CLANG_LATEST_VERSION} 1000
        sudo update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-${CLANG_LATEST_VERSION} 1000
        sudo update-alternatives --install /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-${CLANG_LATEST_VERSION} 1000
        sudo update-alternatives --install /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-${CLANG_LATEST_VERSION} 1000

        sudo update-alternatives --config clang
        sudo update-alternatives --config clang++
        sudo update-alternatives --config ld.lld
        sudo update-alternatives --config llvm-ar
        sudo update-alternatives --config llvm-ranlib
    else
        echo "LLVM already at the latest version"
    fi
fi

echo "installing LLVM OpenMP"

sudo ${PACKAGE_MANAGER} install -y --allow-unauthenticated libomp5

echo "Creating required environment variables..."

export MK_DIR=/usr/local/makekit
export MK_LLVM_DIR=`command -v clang-${CLANG_LATEST_VERSION} | xargs readlink -f | xargs dirname | xargs dirname`
export MK_QT_DIR=""

# Update also in user profile, making them permanent
sed -i '/# MakeKit/d' ${HOME}/.profile
sed -i '/MK_/d' ${HOME}/.profile

echo "# MakeKit" >> ${HOME}/.profile
echo "export MK_DIR=${MK_DIR}" >> ${HOME}/.profile
echo "export MK_LLVM_DIR=${MK_LLVM_DIR}" >> ${HOME}/.profile
echo "export MK_QT_DIR=${MK_QT_DIR}" >> ${HOME}/.profile

if [ -d ${MK_DIR} ] ; then
    echo "Removing existing MakeKit installation..."
    sudo rm -rf ${MK_DIR}
fi

echo "Compiling MakeKit executable..."

mkdir ${DIR}/bin
clang++ -o ${DIR}/bin/mk ${DIR}/src/mk.cpp

echo "Copying files to '${MK_DIR}'..."

sudo mkdir -p ${MK_DIR}
sudo cp -rv ${DIR}/bin ${MK_DIR}/bin
sudo cp -rv ${DIR}/cmake ${MK_DIR}/cmake
sudo cp -rv ${DIR}/integration ${MK_DIR}/integration

echo "Creating required symbolic links..."

if [ -f /usr/local/bin/mk ] ; then
    sudo rm -f /usr/local/bin/mk
fi

sudo ln -s ${MK_DIR}/bin/mk /usr/local/bin/mk

echo "Cleaning up..."

rm -rf ${DIR}/bin

