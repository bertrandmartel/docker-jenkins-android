#!/bin/bash -e

export SDK_PATH=$1
export NDK_PATH=$2
export ANDROID_SDK=$3
export ANDROID_NDK=$4
export ANDROID_NDK_HOME=${NDK_PATH}/${ANDROID_NDK}
export ANDROID_HOME=$SDK_PATH

: "${ANDROID_HOME:="$ANDROID_HOME"}"
: "${ANDROID_SDK_ROOT:="$ANDROID_HOME"}"
: "${ANDROID_NDK_HOME:="$ANDROID_NDK_HOME"}"

echo "ANDROID_HOME     : $ANDROID_HOME"
echo "ANDROID_NDK_HOME : $ANDROID_NDK_HOME"
echo "ANDROID_SDK_ROOT : $ANDROID_SDK_ROOT"
echo "ERASE_ANDROID_SDK : $ERASE_ANDROID_SDK"
echo "ERASE_ANDROID_NDK : $ERASE_ANDROID_NDK"

export PATH=$PATH:$ANDROID_NDK_HOME:$ANDROID_HOME/tools

if [ "$ERASE_ANDROID_NDK" == 1 ]; then
	echo "removing ndk directory content..."
	rm -rf ${NDK_PATH}/*
fi

# check if NDK is present
if hash ndk-build 2>/dev/null; then
    echo "Android NDK already exists"
else
	mkdir -p ${NDK_PATH}
	echo "downloading NDK..."
	wget --no-verbose https://dl.google.com/android/repository/${ANDROID_NDK}-linux-x86_64.zip -O ${NDK_PATH}/ndk.zip
	unzip ${NDK_PATH}/ndk.zip -d ${NDK_PATH} && rm ${NDK_PATH}/ndk.zip
	echo "Android NDK has been installed to ${NDK_PATH}"
fi

if [ "$ERASE_ANDROID_SDK" == 1 ]; then
	echo "removing sdk directory content..."
	rm -rf ${SDK_PATH}/*
fi

# check if SDK is present
if hash android 2>/dev/null; then
    echo "Android SDK already exists"
else
	mkdir -p ${SDK_PATH}
	echo "downloading SDK..."
	wget --no-verbose https://dl.google.com/android/repository/tools_${ANDROID_SDK}-linux.zip -O ${SDK_PATH}/sdk.zip
	unzip ${SDK_PATH}/sdk.zip -d ${SDK_PATH} && rm ${SDK_PATH}/sdk.zip
	echo "Android SDK has been installed to ${NDK_PATH}"
fi

mkdir -p "$SDK_PATH/licenses" || true
echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$SDK_PATH/licenses/android-sdk-license"
echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$SDK_PATH/licenses/android-sdk-preview-license"

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

/sbin/tini -- /usr/local/bin/jenkins.sh
