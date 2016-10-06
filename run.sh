#!/bin/bash

chown -R jenkins:jenkins /var/jenkins_home
chown -R jenkins:jenkins $SDK_PATH
chown -R jenkins:jenkins $NDK_PATH

if [ -z "$VERSION_ANDROID_NDK" ]; then
	export VERSION_ANDROID_NDK=android-ndk-r12b
fi

if [ -z "$ANDROID_SDK" ]; then
	export ANDROID_SDK=r25.2.2
fi

chroot --userspec=jenkins / /usr/local/install.sh $SDK_PATH $NDK_PATH $ANDROID_SDK $VERSION_ANDROID_NDK