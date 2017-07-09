#!/usr/bin/env bash
NAME=$1
boilr template download zenoss/zenkit-template zenkit
/usr/bin/expect -f <(cat <<EOF
spawn -noecho boilr template use zenkit $NAME
expect -re ".*Please choose a value for \"Name\".*"
send "$NAME\n"

interact

exit
EOF
)
