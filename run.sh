#!/bin/bash

chown -R jenkins:jenkins /var/jenkins_home

chroot --userspec=jenkins / /bin/tini -- /usr/local/bin/jenkins.sh