#!/bin/bash

usage() {
        echo "Usage: $0 <ips_file>"
        echo
        echo "this script remove ':None' or the '<fake_ip>, <real_ip>' from ips_file"
        echo
}


if [[ "$#" -lt 1 ]];then
        echo "need to provide input file"
        usage
        exit 1;
fi

for ip in $(cat "$1");do
        if [ "$ip" != "ip_usuario" ];then
                if [[ "$ip" == *","* ]]; then
                        echo "$ip" | cut -d',' -f2 | sed 's/^ //g' >> ips_noport.txt
                else
                        echo "$ip" | sed "s/:None//g" >> ips_noport.txt
                fi
        fi
done

cat ips_noport.txt | sort -u >> blacklist.txt
cat blacklist.txt | sort -u > nblk.txt

rm ips_noport.txt
rm blacklist.txt
rm "$1"

mv nblk.txt blacklist.txt
