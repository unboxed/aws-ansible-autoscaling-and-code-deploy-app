#!/bin/bash

if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || "$1" == "--help" ]]; then
  echo "Please supply four arguments - the s3 bucket prefix, the app name, the environment, and a git reg"
  echo "EG: (eg: 'yourname blog dev master' / 'yourname blog staging HEAD' / 'yourname blog production GIT_SHA_OVER_HERE'"
  echo "Note that the app name must match the destination value in the appspec.yml file"
  exit
fi

BUCKET="$1-$2-$3-releases"
TIMESTAMP=`date +%s`

set -o pipefail
set -e

echo "Copying app"
TMPFILE=$(mktemp /tmp/push-app-to-s3-tar-XXXXXXXXXXXX).tar.gz
git archive HEAD --format=tar | gzip -c > ${TMPFILE}

aws s3 cp ${TMPFILE} s3://${BUCKET}/app-${TIMESTAMP}.tar.gz

# Starting deploy
aws deploy create-deployment --application-name=$2-$3 --deployment-group-name=RailsAppServers --s3-location bundleType=tgz,bucket=${BUCKET},key=app-${TIMESTAMP}.tar.gz

rm -f ${TMPFILE}
echo "SUCCESS"
