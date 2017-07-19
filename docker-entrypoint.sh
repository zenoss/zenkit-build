#!/usr/bin/env bash

USER_ID=${LOCAL_USER_ID:-9001}

WORKDIR=${PWD}
for f in ${SYMLINKS}; do
	LINK=(${f//:/ })
	mkdir -p $(dirname ${LINK[1]})
	rm -rf ${LINK[1]}
	ln -s ${LINK[0]} ${LINK[1]}
done
cd ${WORKDIR}

adduser -D -s /bin/bash -u $USER_ID -g "" user 2>/dev/null
export HOME=/home/user
exec /sbin/su-exec user "$@"
