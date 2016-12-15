FROM jenkins:latest

MAINTAINER Bertrand Martel <bmartel.fr@gmail.com>

USER root

# install lib32stdc++6 lib32z1 for aapt && build-essential and file for ndk
RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1 build-essential file

COPY docker-entrypoint.sh /
COPY run.sh /
COPY install.sh /usr/local/install.sh
COPY cert.sh /usr/local/cert.sh

ENV NDK_PATH "/opt/android/ndk"
ENV SDK_PATH "/opt/android/sdk"

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /run.sh
RUN chmod 777 /usr/local/install.sh
RUN chmod 777 /usr/local/cert.sh

RUN /usr/local/bin/install-plugins.sh gitlab-plugin:1.4.0 android-emulator:2.15 gitlab-logo:1.0.1 gitlab-oauth:1.0.8 ws-cleanup:0.30 slack:2.0.1 embeddable-build-status:1.9 gradle:1.25

COPY gitlab-oauth.hpi /usr/share/jenkins/ref/plugins/gitlab-oauth.jpi

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/run.sh"]