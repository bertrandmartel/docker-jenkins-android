#!/bin/bash -e

: "${ANDROID_HOME:="$1"}"
: "${ANDROID_SDK_ROOT:="$1"}"
: "${ANDROID_NDK_HOME:="$2"}"

echo "ANDROID_HOME     : $ANDROID_HOME"
echo "ANDROID_NDK_HOME : $ANDROID_NDK_HOME"
echo "ANDROID_SDK_ROOT : $ANDROID_SDK_ROOT"

export PATH=$PATH:$ANDROID_NDK_HOME:$ANDROID_HOME/tools

# check if NDK is present
if hash ndk-build 2>/dev/null; then
    echo "Android NDK already exists"
else
	mkdir -p ${NDK_PATH}
	echo "downloading NDK..."
	wget --no-verbose https://dl.google.com/android/repository/${VERSION_ANDROID_NDK}-linux-x86_64.zip -O ${NDK_PATH}/ndk.zip
	unzip ${NDK_PATH}/ndk.zip -d ${NDK_PATH} && rm ${NDK_PATH}/ndk.zip
	echo "Android NDK has been installed to ${NDK_PATH}"
fi

# check if SDK is present
if hash android 2>/dev/null; then
    echo "Android SDK already exists"
else
	mkdir -p ${SDK_PATH}
	echo "downloading SDK..."
	wget --no-verbose https://dl.google.com/android/repository/tools_${VERSION_ANDROID_SDK}-linux.zip -O ${SDK_PATH}/sdk.zip
	unzip ${SDK_PATH}/sdk.zip -d ${SDK_PATH} && rm ${SDK_PATH}/sdk.zip
	echo "Android SDK has been installed to ${NDK_PATH}"
fi

echo y | android update sdk --no-ui

if [ ! -z "$ANDROID_BUILD_TOOLS_FILTER" ]; then

	IFS=',' read -ra ADDR <<< "$ANDROID_BUILD_TOOLS_FILTER"
	for i in "${ADDR[@]}"; do
		if [ ! -e "$ANDROID_HOME/build-tools/$i" ]; then
			PACKAGES=$PACKAGES,build-tools-$i
		fi
	done

	if [ ! -z "$PACKAGES" ]; then
		echo "installing $PACKAGES"
		echo y | android update sdk -a --filter $PACKAGES --no-ui
	else
		echo "no build-tools packages to update"
	fi
fi

/bin/tini -- /usr/local/bin/jenkins.sh