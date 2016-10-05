#!/bin/bash

mkdir -p /var/jenkins_home/.android

chown -R jenkins:jenkins /var/jenkins_home

if [ -z "$VERSION_ANDROID_NDK" ]; then
	export VERSION_ANDROID_NDK=android-ndk-r12b
fi

if [ -z "$VERSION_ANDROID_SDK" ]; then
	export VERSION_ANDROID_SDK=r25.2.2
fi

export ANDROID_NDK_HOME=${NDK_PATH}/${VERSION_ANDROID_NDK}
export PATH=$PATH:$ANDROID_NDK_HOME:$SDK_PATH/tools
export ANDROID_HOME=$SDK_PATH

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

if [ ! -z "$ANDROID_SDK_FILTER" ]; then
	echo y | android update sdk -a --filter $ANDROID_SDK_FILTER --no-ui
fi

chown -R jenkins:jenkins $NDK_PATH
chown -R jenkins:jenkins $SDK_PATH

chroot --userspec=jenkins / /bin/tini -- /usr/local/bin/jenkins.sh $ANDROID_HOME $ANDROID_NDK_HOME 