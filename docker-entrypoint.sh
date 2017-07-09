#!/usr/bin/env bash

USER_ID=${LOCAL_USER_ID:-9001}
adduser -D -s /bin/bash -u $USER_ID -g "" user
export HOME=/home/user
exec /sbin/su-exec user "$@"
