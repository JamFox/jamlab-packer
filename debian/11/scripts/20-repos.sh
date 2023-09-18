#!/bin/bash

set -e

if [[ "$BACKPORTS" = "yes" ]]; then
    cat << EOF >> /etc/apt/sources.list

deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free
EOF
fi
