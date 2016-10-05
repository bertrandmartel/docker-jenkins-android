#! /bin/bash -e
: "${ANDROID_HOME:="$1"}"
: "${ANDROID_SDK_ROOT:="$1"}"
: "${ANDROID_NDK_HOME:="$2"}"
: "${JENKINS_HOME:="/var/jenkins_home"}"

touch "${COPY_REFERENCE_FILE_LOG}" || { echo "Can not write to ${COPY_REFERENCE_FILE_LOG}. Wrong volume permissions?"; exit 1; }
echo "--- Copying files at $(date)" >> "$COPY_REFERENCE_FILE_LOG"
find /usr/share/jenkins/ref/ -type f -exec bash -c '. /usr/local/bin/jenkins-support; for arg; do copy_reference_file "$arg"; done' _ {} +

echo "ANDROID_HOME     : $ANDROID_HOME"
echo "ANDROID_NDK_HOME : $ANDROID_NDK_HOME"
echo "ANDROID_SDK_ROOT : $ANDROID_SDK_ROOT"
echo "JENKINS_HOME     : $JENKINS_HOME"

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -le 2 ]] || [[ "$1" == "--"* ]]; then

  # read JAVA_OPTS and JENKINS_OPTS into arrays to avoid need for eval (and associated vulnerabilities)
  java_opts_array=()
  while IFS= read -r -d '' item; do
    java_opts_array+=( "$item" )
  done < <([[ $JAVA_OPTS ]] && xargs printf '%s\0' <<<"$JAVA_OPTS")

  jenkins_opts_array=( )
  while IFS= read -r -d '' item; do
    jenkins_opts_array+=( "$item" )
  done < <([[ $JENKINS_OPTS ]] && xargs printf '%s\0' <<<"$JENKINS_OPTS")

  if [ $# -gt 2 ]; then
    ARGS="${@:3}"
  else
    ARGS=""
  fi
  exec java "${java_opts_array[@]}" -jar /usr/share/jenkins/jenkins.war "${jenkins_opts_array[@]}" "$ARGS"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"