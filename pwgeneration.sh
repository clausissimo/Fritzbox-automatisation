#!/bin/bash
# This script provides to generate random pw for fritzbox guest wlan. Tested with version 6.0 and 6.1.
# Further versions will also extract generated qr code. 
#
# config
# ---------------------------------------
# url fritzbox
_URL="http://fritz.box"
# password fritzbox login
_PASSWORD="your_pw"
# ssid of guest wlan
_SSID="your_ssid"
# set your own password rules minimal pw length is 8 chars 
_RANDPW=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
# ---------------------------------------
_CHALLENGE=$(curl -s ${_URL}/login.lua | grep "^g_challenge" | awk -F '"' '{ print $2 }')
_MD5=$(echo -n ${_CHALLENGE}"-"${_PASSWORD} | iconv -f ISO8859-1 -t UTF-16LE | md5sum -b | awk '{print substr($0,1,32)}')
_RESPONSE=${_CHALLENGE}"-"${_MD5}
_SESSION=$(curl -i -s -k -d 'response='${_RESPONSE} -d 'page=' ${_URL}/login.lua | grep "Location:" | awk -F '=' {' print $NF '})

_PAGE_PFW=$(curl -s "${_URL}/wlan/guest_access.lua" -d 'sid='${_SID}) 
#_RULES=$(echo "$_PAGE_PFW")
#echo -e "$_RULES"

# set generate pw
curl --data "activate_guest_access=on&autoupdate=on&btnSave=&group_access=on&guest_ssid=${_SSID}&sec_mode=4&wpa_key=${_RANDPW}" ${_URL}/wlan/guest_access.lua -d 'sid='${_SESSION}

