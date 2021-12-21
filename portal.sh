#!/usr/bin/env bash
# portal.sh -- UPDATE WEB PORTAL
# v0.1.4  oct/2021  mountaineerbr
#   __ _  ___  __ _____  / /____ _(_)__  ___ ___ ____/ /  ____
#  /  ' \/ _ \/ // / _ \/ __/ _ `/ / _ \/ -_) -_) __/ _ \/ __/
# /_/_/_/\___/\_,_/_//_/\__/\_,_/_/_//_/\__/\__/_/ /_.__/_/   
set -e

#blog root
ROOT="$HOME/www/bionota.github.io"
#website root
ROOTW="https://bionota.github.io"


#start
cd "$ROOT" || exit


#update blog pages
"$ROOT"/bin/blog.sh "$@"
echo


#generate sitemaps
"$ROOT"/bin/sitemaps.sh
echo

