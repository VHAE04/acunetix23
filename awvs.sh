#!/usr/bin/env bash
# clear
echo -e "\033[1;31m      ___ _       ___    _______ \033[0m"
echo -e "\033[1;32m     /   | |     / / |  / / ___/ \033[0m"
echo -e "\033[1;33m    / /| | | /| / /| | / /\__ \\  \033[0m"
echo -e "\033[1;34m   / ___ | |/ |/ / | |/ /___/ /  \033[0m"
echo -e "\033[1;35m  /_/  |_|__/|__/  |___//____/   \033[0m"
# shellcheck disable=SC2002
echo -e "\n\033[1;36m  [ Version: $(cat /awvs/LAST_VERSION | sed 's/ //g' 2>/dev/null) ] \033[0m"
echo -e "\033[1;34m  ------------------------------------------------- \033[0m"
echo -e "\033[1;31m  Thank's fahai && Open Source Enthusiast \n\033[0m"

echo -e "\033[1;32m  [ help ] \033[0m"
echo -e "\033[1;33m  [ https://www.fahai.org ] \033[0m"
echo -e "\033[1;33m  [ https://github.com/XRSec/AWVS-Update ] \033[0m"
echo -e "\033[1;33m  [ https://awvs.vercel.app/ ] \n\033[0m"

echo -e "\033[1;32m  [ INFO ] \033[0m"
echo -e "\033[1;33m  [ Username: awvs@awvs.lan ] \033[0m"
echo -e "\033[1;33m  [ Password: Awvs@awvs.lan ] \n\033[0m"

echo -e "\033[1;32m  [ IP ] \033[0m"
echo -e "\033[1;33m  [ https://awvs.lan:3443/ ] \033[0m"
ifconfig -a | grep inet | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | awk '{print "\033[1;33m  [ https://" $1 ":3443 ] \033[0m"}'
echo -e "\033[1;33m  [ https://$(curl -s -m 10 myip.ipip.net | cut -d " " -f 2 | tr -d "IP："):3443 ] \n\033[0m"

cat /awvs/.hosts >> /etc/hosts
grep acunetix /etc/hosts
su -l acunetix -c /home/acunetix/.acunetix/start.sh
