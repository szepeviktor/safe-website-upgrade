#!/bin/bash
#
# Make a snapshot of listed pages in a normalized form
#
# DEPENDS       :apt-get install wget dos2unix xmlstarlet libxml2-utils openjdk-17-jre-headless
# DEPENDS       :https://github.com/validator/validator

set -e

DIRECTORY="$(date "+%s")"
mkdir "${DIRECTORY}"
cd "${DIRECTORY}"

wget "https://EXAMPLE.COM/.well-known/safe-upgrade/urls"

while read -r URL; do
    SLUG="$(echo "${URL}" | iconv -t "ascii//TRANSLIT" | sed -e 's#[^0-9A-Za-z-]#_#g')"
    wget -qSO- "${URL}" 1>"${SLUG}.html" 2>"${SLUG}.headers"
    grep -q -F -i '</html>' "${SLUG}.html"
    # Fixes
    sed -i -e 's#pswp__preloader--active#pswp__preloader- -active#' "${SLUG}.html"
    java -jar vnu.jar --Werror "${SLUG}.html"
    dos2unix -k -n "${SLUG}.html" "${SLUG}.html.lf"
    expand --tabs=4 "${SLUG}.html.lf" >"${SLUG}.html.lf.space"
    xmlstarlet fo --html --recover "${SLUG}.html.lf.space" >"${SLUG}.xml.original" 2>/dev/null
    # Fixes
    #xmlstarlet ed --delete '//path'
    xmllint --format --output "${SLUG}.xml" "${SLUG}.xml.original"
done <urls

ls -1 -t -r ./*.xml
