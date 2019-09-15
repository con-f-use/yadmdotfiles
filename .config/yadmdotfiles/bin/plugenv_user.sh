#!/bin/bash

grep -qEo "^plugdev:" /etc/group || sudo groupadd plugdev
group | grep -qo plugdev || sudo usermod -a -G plugdev $USER

