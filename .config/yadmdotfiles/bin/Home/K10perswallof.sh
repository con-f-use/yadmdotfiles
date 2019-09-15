#! /bin/bash

LINKPATH=/etc/rc6.d/K10perswallof.sh
USBTOOL='/home/confus/misc/gbin/usbtool -w -P PERswitch control in vendor device 2'

if [ "$1" = "link" ]; then
    echo "This script will be linked to '$LINKPATH'"
    ORIGIN="$(readlink -f $0)"
    sudo ln -s "$ORIGIN" "$LINKPATH"
    LINKPATH="${LINKPATH/rc6.d/rc0.d}"
    sudo ln -s "$ORIGIN" "$LINKPATH"
    exit 0;
fi

function foo {
    $USBTOOL 0X0202 0
    $USBTOOL 0X0203 0
    $USBTOOL 0X0204 0
    $USBTOOL 0X0205 0
}

foo
#foo >> /home/confus/bin/perswalloff.log 
exit 0;
