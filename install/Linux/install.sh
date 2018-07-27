#!/bin/bash

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
    echo "Debian found"
    PACKAGE_MANAGER=apt-get
    sudo ${PACKAGE_MANAGER} update
else
    echo "ERROR: Unknown distribution"
    exit 1
fi

echo "Detecting Ninja..."

if ! [ -x "$(command -v ninja)" ] ; then
    # Install Ninja
    echo "Ninja not found, installing via package manager..."
    sudo ${PACKAGE_MANAGER} install ninja-build
else
    # Print Ninja version
    echo "Ninja found, version: "`ninja --version`
fi

echo "Detecting LLVM 6.0..."

if ! [ -x "$(command -v clang-6.0)" ] ; then
	# Install LLVM
	echo "LLVM 6.0 not found, installing via package manager..."
	sudo ${PACKAGE_MANAGER} install clang-6 lldb-6 lld-6 libomp5
else
	# Print LLVM found info
	echo "LLVM 6.0 found"
fi

echo "Creating required environment variables..."

export MAKEKIT_DIR=/usr/local/makekit
export MAKEKIT_LLVM_DIR=`command -v clang-6.0 | xargs readlink -f | xargs dirname | xargs dirname`
export MAKEKIT_QT_DIR=""

# Update also in user profile, making them permanent
sed -i '/# MakeKit/d' ${HOME}/.profile
sed -i '/MAKEKIT_/d' ${HOME}/.profile
echo "# MakeKit" >> ${HOME}/.profile
echo "MAKEKIT_DIR=${MAKEKIT_DIR}" >> ${HOME}/.profile
echo "MAKEKIT_LLVM_DIR=${MAKEKIT_LLVM_DIR}" >> ${HOME}/.profile
echo "MAKEKIT_QT_DIR=${MAKEKIT_QT_DIR}" >> ${HOME}/.profile

if [ -d ${MAKEKIT_DIR} ] ; then
    echo "Removing existing MakeKit installation..."
    sudo rm -rf ${MAKEKIT_DIR}
fi

echo "Compiling MakeKit executable..."
clang++ -o ${DIR}/bin/mk ${DIR}/src/mk.cpp

echo "Copying files to '${MAKEKIT_DIR}'..."

sudo mkdir -p ${MAKEKIT_DIR}
sudo cp -rv ${DIR}/bin ${MAKEKIT_DIR}/bin
sudo cp -rv ${DIR}/cmake ${MAKEKIT_DIR}/cmake
sudo cp -rv ${DIR}/integration ${MAKEKIT_DIR}/integration

echo "Creating required symbolic links..."

if [ -f /usr/local/bin/mk ] ; then
    sudo rm -f /usr/local/bin/mk
fi

sudo ln -s ${MAKEKIT_DIR}/bin/mk /usr/local/bin/mk

