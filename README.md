# Jenkins Docker image

A jenkins docker image with the following pre-installed plugins :
* gitlab-plugin
* android-emulator
* gitlab-logo
* gitlab-oauth

Some packages are also pre-installed to build Android application correcly

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

```
openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out pkcs.p12 -name ALIAS

keytool -importkeystore -deststorepass PASSWORD_STORE -destkeypass PASSWORD_KEYPASS \
        -destkeystore keystore.jks -srckeystore pkcs.p12 -srcstoretype PKCS12 -srcstorepass STORE_PASS  \
        -alias ALIAS
```