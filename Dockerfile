FROM jenkins:latest

USER root

# install lib32stdc++6 lib32z1 for aapt
RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1

COPY docker-entrypoint.sh /
COPY run.sh /

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /run.sh

RUN /usr/local/bin/install-plugins.sh gitlab-plugin:1.4.0 android-emulator:2.15 gitlab-logo:1.0.1 gitlab-oauth:1.0.8

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/run.sh"]