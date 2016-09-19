FROM jenkins:latest

MAINTAINER Bertrand Martel <bmartel.fr@gmail.com>

USER root

# install lib32stdc++6 lib32z1 for aapt
RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1

COPY docker-entrypoint.sh /
COPY run.sh /

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /run.sh

RUN /usr/local/bin/install-plugins.sh gitlab-plugin:1.4.0 android-emulator:2.15 gitlab-logo:1.0.1 gitlab-oauth:1.0.8 ws-cleanup:0.30 slack:2.0.1 embeddable-build-status:1.9

COPY ./gitlab-oauth.hpi /usr/share/jenkins/ref/plugins/gitlab-oauth.jpi

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/run.sh"]