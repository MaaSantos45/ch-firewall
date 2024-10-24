#!/bin/bash

mysql -u root -p < get_ips.sql > ips.txt
./port_replace.sh ips.txt
