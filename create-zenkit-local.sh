#!/usr/bin/env bash
NAME=$1
boilr template save $GOPATH/src/github.com/zenoss/zenkit-template zenkit
/usr/bin/expect -f <(cat <<EOF
spawn -noecho boilr template use zenkit $NAME
expect -re ".*Please choose a value for \"Name\".*"
send "$NAME\n"
expect -re ".*Please choose a value for \"Port\".*"
send "\n"
expect -re ".*Please choose a value for \"Title\".*"
send "\n"
expect -re ".*Please choose a value for \"Description\".*"
send "\n"

expect eof
wait
exit
EOF
)
