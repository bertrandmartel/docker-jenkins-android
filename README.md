# Jenkins Docker image for Android dev

[![Build Status](https://travis-ci.org/akinaru/docker-jenkins.svg?branch=master)](https://travis-ci.org/akinaru/docker-jenkins)
[![](https://images.microbadger.com/badges/version/akinaru/docker-jenkins.svg)](https://microbadger.com/images/akinaru/docker-jenkins)
[![](https://images.microbadger.com/badges/image/akinaru/docker-jenkins.svg)](https://microbadger.com/images/akinaru/docker-jenkins)

A jenkins docker image with Android SDK/NDK global install and the following pre-installed plugins :
* [gitlab-plugin](https://wiki.jenkins-ci.org/display/JENKINS/GitLab+Plugin) : build trigger on push
* [gitlab-logo](https://wiki.jenkins-ci.org/display/JENKINS/GitLab+Logo+Plugin) : gitlab repo icon on dashboard 
* [gitlab-oauth](https://wiki.jenkins-ci.org/display/JENKINS/GitLab+OAuth+Plugin) : gitlab authentication
* [android-emulator](https://wiki.jenkins-ci.org/display/JENKINS/Android+Emulator+Plugin) : use android emulator in CI
* [ws-cleanup](https://wiki.jenkins-ci.org/display/JENKINS/Workspace+Cleanup+Plugin) : clean workspace before build
* [slack](https://wiki.jenkins-ci.org/display/JENKINS/Slack+Plugin) : send slack notifications
* [Embeddable Build Status Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Embeddable+Build+Status+Plugin) : build status badge

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/architecture.png)

Other packages are also downloaded to build Android applications correctly

## Run

```
docker run -p 8080:8080 -p 50000:50000 \
           -v /home/user/Android/sdk:/opt/android/sdk \
           -v /home/user/Android/ndk:/opt/android/ndk \
           -v your_home/jenkins_home:/var/jenkins_home akinaru/docker-jenkins-android
```

## Environment variables

| Variable name                    |  description       | sample value                                      |
|----------------------------------|---------------------------------|------------------------------------------------------------------------|
| ANDROID_SDK        | Android SDK release name   | r25.2.2 |
| ANDROID_NDK            | Android NDK release name  | android-ndk-r12b |
| ERASE_ANDROID_SDK      | clear SDK directory before installing a new one | 1 or 0 |
| ERASE_ANDROID_NDK      | clear NDK directory before installing a new one | 1 or 0 |
| ANDROID_BUILD_TOOLS_FILTER       | additionnal build tools versions to install comma separated  | 23.0.2,23.0.3   |

Example :

```
docker run -p 8080:8080 -p 50000:50000 \
           -e "ANDROID_BUILD_TOOLS_FILTER=23.0.2,23.0.3" \
           -e "ANDROID_SDK=r25.2.2" \
           -e "ANDROID_NDK=android-ndk-r12b" \
           -v /home/user/Android/sdk:/opt/android/sdk \
           -v /home/user/Android/ndk:/opt/android/ndk \
           -v your_home/jenkins_home:/var/jenkins_home akinaru/docker-jenkins-android
```

## docker-compose

https configuration is enabled by default with `keystore.jks` in a `keys` directory :

```
docker-compose up
```

## docker-cloud

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

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/gitlab_app.png)

Then, you will have generated `Application ID` (client ID) and Secret (Client Secret) : 

***

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/gitlab_token.png)

***

* Go to `Manage Jenkins` > `Configure Global Security`

Fill up checking `Gitlab Authentication Plugin` in `Access control` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/oauth.png)

***

Now, Jenkins user will be authenticated via Gitlab

## Configure Giltab push trigger

In `Manage Jenkins` > `Configure System` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/gitlab-connection.png)

Gitlab URL is : `https://<your host>:<your port>`

***

Enter a Gitlab API Token that you got from Gitlab in `Profile Settings` > `Access Tokens` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/access-token.png)

***

In your job configuration, Set `GitLab connection` and `Git` repository config as :

* Repository URL : `git@server/repo.git`
* Name : `origin`
* RefSpec : `+refs/heads/*:refs/remotes/origin/* +refs/merge-requests/*/head:refs/remotes/origin/merge-requests/*`
* Branch specifier : `origin/${gitlabSourceBranch}`

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/git-config.png)

***

In `Build Trigger`, set `Build when a changed is pushed to Gitlab` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/build-trigger.png)

***

In your gitlab repository go to `Webhooks` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/webhook-settings.png)

Then, set the webhook URL as : `https://<jenkins-host>:<port>/project/<your job>` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/webhook.png)

***

## Configure Giltab Logo

In `Manage Jenkins` > `Configure System` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/gitlab-logo.png)

`Endpoint URL` is : `https://<your-gitlab-host>:<port>/api/v3`

***

## Configure Slack notifications

* go to https://my.slack.com/services/new/jenkins-ci

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/slack.png)

***

In your job configuration, add a Slack Notification `Post Build Action` :

![](https://github.com/akinaru/docker-jenkins-android/raw/master/img/slack-post-build.png)

***

## External Links

* gitlab-plugin setup example : https://github.com/jenkinsci/gitlab-plugin/wiki/Setup-Example
* gitlab-oauth-plugin webhook fix : https://github.com/jenkinsci/gitlab-oauth-plugin/pull/6
