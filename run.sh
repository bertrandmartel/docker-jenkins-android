#!/bin/bash

chown -R jenkins:jenkins /var/jenkins_home

if [ -z "$VERSION_ANDROID_NDK" ]; then
	export VERSION_ANDROID_NDK=android-ndk-r12b
fi

if [ -z "$VERSION_ANDROID_SDK" ]; then
	export VERSION_ANDROID_SDK=r25.2.2
fi

export ANDROID_NDK_HOME=${NDK_PATH}/${VERSION_ANDROID_NDK}
export ANDROID_HOME=$SDK_PATH

chroot --userspec=jenkins / /usr/local/install.sh $ANDROID_HOME $ANDROID_NDK_HOME