#!/usr/bin/env bash
NAME=$1
boilr template save $GOPATH/src/github.com/zenoss/zenkit-template zenkit
/usr/bin/expect -f <(cat <<EOF
spawn -noecho boilr template use zenkit $NAME
expect -re ".*Please choose a value for \"Name\".*"
send "$NAME\n"
expect {
    -re "Please choose a value for \"\[a-zA-Z0-9]+\".*" {
        send "\n"
        exp_continue
    }
    eof { exit }
}
wait
exit
EOF
)
