#!/bin/bash

if [[ "$#" -lt 1 ]];then
        echo "need to provide a input file with sql"
        exit 1;
fi

mysql -u root -p < "$1" > ips.txt
ls -lah ips.txt
./port_replace.sh ips.txt
