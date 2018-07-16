echo Detecting Homebrew...

which -s brew
if [[ $? != 0 ]] ; then
	# Install Homebrew
	echo Homebrew not found, installing...
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	# Update Homebrew
	brew -v
	echo Homebrew found, updating...
	brew update
	brew upgrade
fi

echo Detecting Ninja...

brew ls --versions ninja
if [[ $? != 0 ]] ; then
    # Install Ninja
    echo Ninja not found, installing...
    brew install ninja
else
    # Update Ninja
    brew info ninja
    echo Ninja found, updating...
    brew upgrade ninja
fis

echo Detecting LLVM...

brew ls --versions llvm
if [[ $? != 0 ]] ; then
	# Install LLVM
	echo LLVM not found, installing...
	brew install --with-toolchain llvm

	echo Adding LLVM binaries to PATH...
	echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.bash_profile
else
	# Update LLVM
	brew info llvm
	echo LLVM found, updating...
	brew upgrade llvm
fi

echo Copying files to /usr/local/bin/...

sudo cp mk /usr/local/bin/
sudo cp mk_clean /usr/local/bin/
sudo cp mk_config /usr/local/bin/
sudo cp mk_make /usr/local/bin/
sudo cp mk_remake /usr/local/bin/
