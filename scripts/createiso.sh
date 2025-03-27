#!/bin/bash

if [ -z "$REPO" ]; then
  export DATE=$(date '+%Y%m%d-%H%M')
  echo "Setting Date: $DATE"
else
  echo "Date already set: $DATE"
fi

export REPO=${1}
export VERSION=$(grep -oP '(?<=VERSION_ID=")[^.]+' /etc/os-release)

if [ -z "$REPO" ]; then
  echo "No repository specified. Exiting."
  exit 1
fi

if [ ! -d "$REPO" ]; then
  echo "Directory $REPO does not exist. Exiting."
  exit 1
fi

echo "Making TOC of ${REPO}"
tree ${REPO} \
  | tee ${REPO}/${REPO}-${VERSION}}-${DATE}.iso.txt

echo -e "\nWorking on repo $REPO\n"

echo "Build short repo name"
case $REPO in
  *"baseos"*) SHORT_REPO="BaseOS${VERSION}" ;;
  *"appstream"*) SHORT_REPO="AppStream${VERSION}" ;;
  *"codeready-builder"*) SHORT_REPO="CRB${VERSION}" ;;
  *"epel"*) SHORT_REPO="EPEL${VERSION}" ;;
  *"docker-ce-stable"*) SHORT_REPO="Docker${VERSION}" ;;
esac
echo "SHORT_REPO=$SHORT_REPO"

echo "Making ISO of ${REPO}"
mkisofs -r -v -l \
  -V ${SHORT_REPO}-${DATE} \
  -A ${SHORT_REPO}-${DATE} \
  -o ${REPO}-${VERSION}-${DATE}.iso \
  ${REPO}

echo "Implanting MD5 into ISO"
implantisomd5 ${REPO}-${VERSION}}-${DATE}.iso

echo "Generating SHA256 of ISO"
sha256sum -b ${REPO}-${VERSION}}-${DATE}.iso | tee \
  ${REPO}-${VERSION}-${DATE}.iso.sha