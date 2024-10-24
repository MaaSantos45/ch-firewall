#!/bin/bash

usage() {
        echo "Usage: sudo $0 [opts]"
        echo
        echo "This script make changes in iptables, then show the RULES of all chains"
        echo
        echo "Options:"
        echo
        echo "-r                Clear the existing rules"
        echo "-p                Define the policy of INPUT, OUTPUT, FORWARD to ACCEPT"
        echo "-b <filename>     Pass a file with blacklist IPs to DROP in source INPUT and destinate OUTPUT"
        echo
        echo "-d <ip>           Add a IP to blacklist and DROP in source INPUT and destinate OUTPUT"
        echo
        echo "-w <filename>     Pass a file with whitelist IPs to INSERT a ACCEPT in source INPUT and destinate OUTPUT"
        echo
        echo "-a <ip>           Add a IP to whitelist and ACCEPT in source INPUT and destinate OUTPUT"
        echo
        echo "-h                Show this help message"
}

clear_rules() {
        echo "Clearing existing rules"
        iptables -F
        iptables -X
}

define_policy() {
        echo "Defining ACCEPT policy"
        iptables -P INPUT ACCEPT
        iptables -P OUTPUT ACCEPT
        iptables -P FORWARD ACCEPT
}

block_ips() {
        file=$1
        for ip in $(cat $file); do

                echo "blocking $ip"
                iptables -A INPUT -s $ip -j DROP
                iptables -A OUTPUT -d $ip -j DROP

        done
}

bypass_ips() {
        file=$1
        for ip in $(cat $file); do

                echo "unblocking $ip"
                iptables -I INPUT 1 -s $ip -j ACCEPT
                iptables -I OUTPUT 1 -d $ip -j ACCEPT

        done
}

drop_ip() {
        ip=$1
        echo "blocking $ip"
        echo "$ip" >> blacklist.txt
        iptables -A INPUT -s $ip -j DROP
        iptables -A OUTPUT -d $ip -j DROP
}

accept_ip() {
        ip=$1
        echo "unblocking $ip"
        echo "$ip" >> whitelist.txt
        iptables -I INPUT 1 -s $ip -j ACCEPT
        iptables -I OUTPUT 1 -d $ip -j ACCEPT
}

main() {
        echo "Initializing firewall configuration"
        while getopts ":hrpb:d:w:a:" OPT;
        do
                case "${OPT}" in
                        h)
                                usage
                                exit 0
                                ;;
                        r)
                                clear_rules;
                                ;;
                        p)
                                define_policy;
                                ;;
                        b)
                                if [[ "${OPTARG:0:1}" == "-" ]];then
                                        echo "-b require argument"
                                        exit ${OPTIND}
                                fi

                                block_ips $OPTARG
                                ;;

                        d)
                                if [[ "${OPTARG:0:1}" == "-" ]];then
                                        echo "-d require argument"
                                        exit ${OPTIND}
                                fi

                                drop_ip $OPTARG
                                ;;

                        w)
                                if [[ "${OPTARG:0:1}" == "-" ]];then
                                        echo "-w require argument"
                                        exit ${OPTIND}
                                fi

                                bypass_ips $OPTARG
                                ;;

                        a)
                                if [[ "${OPTARG:0:1}" == "-" ]];then
                                        echo "-d require argument"
                                        exit ${OPTIND}
                                fi

                                accept_ip $OPTARG
                                ;;

                        :)
                                echo "-${OPTARG} require argument"
                                usage
                                exit 1
                                ;;

                        ?)
                                "? -${OPTARG} invalid"
                                usage
                                exit 1
                                ;;
                esac
        done
}

if [[ $(whoami) == "root" ]];then
        main "$@"
        echo
        echo "Firewall configured successfully"
        echo
        iptables -S
else
        echo "Need to be run with sudo"
        usage
        exit 1
fi
echo
