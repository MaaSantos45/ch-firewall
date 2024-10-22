#!/bin/bash

if [[ "$#" -lt 1 ]];then
        echo "need to provide input file"
        exit 1;
fi

for ip in $(cat "$1");do
        if [ "$ip" != "ip_usuario" ];then
                echo "$ip" | sed "s/:None//g" >> ips_noport.txt
        fi
done

cat ips_noport.txt | sort -u > blacklist.txt
rm ips_noport.txt
rm "$1"
