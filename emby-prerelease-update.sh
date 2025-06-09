#!/bin/bash
set -eu

# Based on https://github.com/floppy-disk/emby_update

##### UPDATE MEEEEEEEE ##########
readonly SERVER_URL="https://localhost:8920"
#################################

main () {
inst_ver=$(/usr/bin/curl -s -m 10 $SERVER_URL/web/index.html)
inst_ver=$(echo "$inst_ver" \
    | /usr/bin/sed -n '/data-appversion=\"/p' \
    | /usr/bin/awk -F "data-appversion=\"" '{print $2}' \
    | /usr/bin/sed 's/\".*//')
#echo "Current version installed: $inst_ver"

curr_release=$(/usr/bin/curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases | /usr/bin/jq -r 'map(select(.prerelease)) | .[0].tag_name')

if [ "$inst_ver" = "$curr_release" ]; then
    echo "Emby is up to date."
    echo
else
    echo "Upgrading Emby from ${inst_ver} to ${curr_release}"
    download_url=$(/usr/bin/curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases | /usr/bin/jq -r 'map(select(.prerelease)) | .[0].assets[].browser_download_url' | /usr/bin/grep 'x86_64.rpm' | /usr/bin/grep -v '.md5')
    echo "$download_url"
    /usr/bin/dnf install -y "${download_url}"
    echo "Emby has been updated."
    echo "Release notes:"
    curl -s https://api.github.com/repos/MediaBrowser/Emby.Releases/releases | /usr/bin/jq -r 'map(select(.prerelease)) | .[0].body' | /usr/bin/sed 's!\\r\\n!\n!g'
fi
}

main

