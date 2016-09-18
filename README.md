# Jenkins Docker image

[![Build Status](https://travis-ci.org/akinaru/docker-jenkins.svg?branch=master)](https://travis-ci.org/akinaru/docker-jenkins)
[![](https://images.microbadger.com/badges/version/akinaru/docker-jenkins.svg)](https://microbadger.com/images/akinaru/docker-jenkins)
[![](https://images.microbadger.com/badges/image/akinaru/docker-jenkins.svg)](https://microbadger.com/images/akinaru/docker-jenkins)

A jenkins docker image with the following pre-installed plugins :
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/GitLab+Plugin">gitlab-plugin</a> : build trigger on push
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/GitLab+Logo+Plugin">gitlab-logo</a> : gitlab repo icon on dashboard 
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/GitLab+OAuth+Plugin">gitlab-oauth</a> : gitlab authentication
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/Android+Emulator+Plugin">android-emulator</a> : use android emulator in CI
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/Workspace+Cleanup+Plugin">ws-cleanup</a> : clean workspace before build
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/Slack+Plugin">slack</a> : send slack notifications
* <a href="https://wiki.jenkins-ci.org/display/JENKINS/Embeddable+Build+Status+Plugin">Embeddable Build Status Plugin</a> : build status badge

Other packages are also downloaded to build Android applications correctly

## Run

* docker

```
docker run -p 8080:8080 -p 50000:50000 \
           -v your_home/jenkins_home:/var/jenkins_home akinaru/docker-jenkins
```

* docker-compose

https configuration is enabled by default with `keystore.jks` in a `keys` directory :

```
docker-compose up
```

* docker-cloud

Edit `vars-template.sh` configuration, then :
```
source vars-template.sh

envsubst < stackfile-template.yml > stackfile.yml

docker-cloud stack create --name jenkins -f stackfile.yml

docker-cloud start jenkins
```

## Debug

```
docker exec -it jenkins_image bash
```

## Convert server certs to JKS

from <a href="https://maximilian-boehm.com/hp2121/Create-a-Java-Keystore-JKS-from-Let-s-Encrypt-Certificates.htm">this source</a> : 
```
openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out pkcs.p12 -name ALIAS

keytool -importkeystore -deststorepass PASSWORD_STORE -destkeypass PASSWORD_KEYPASS \
        -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -srcstorepass STORE_PASS  \
        -alias ALIAS
```

## Configure Giltab oauth

* In your Gitlab domain go to `Admin` > `Application`

Create a new application with a chosen name and a redirection URI like this : 

* `https://your-jenkins-domain:8083/securityRealm/finishLogin`

![](./img/gitlab_app.png)

Then, you will have generated `Application ID` (client ID) and Secret (Client Secret) : 

<hr/>

![](./img/gitlab_token.png)

<hr/>

* Go to `Manage Jenkins` > `Configure Global Security`

Fill up checking `Gitlab Authentication Plugin` in `Access control` :

![](./img/oauth.png)

<hr/>

Now, Jenkins user will be authenticated via Gitlab