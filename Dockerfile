FROM jenkins/jenkins:lts

MAINTAINER Jeremy Reeve <jeremy.reeve81@gmail.com>

USER root

# install lib32stdc++6 lib32z1 for aapt && build-essential and file for ndk
RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1 build-essential file

COPY docker-entrypoint.sh /
COPY run.sh /
COPY install.sh /usr/local/install.sh
COPY cert.sh /usr/local/cert.sh
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

ENV NDK_PATH "/opt/android/ndk"
ENV SDK_PATH "/opt/android/sdk"

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /run.sh
RUN chmod 777 /usr/local/install.sh
RUN chmod 777 /usr/local/cert.sh

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY gitlab-oauth.hpi /usr/share/jenkins/ref/plugins/gitlab-oauth.jpi

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/run.sh"]