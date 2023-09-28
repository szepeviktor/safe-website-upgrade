#!/bin/bash
#
# Make a snapshot of listed pages in a normalized form
#
# DEPENDS       :apt-get install wget dos2unix xmlstarlet libxml2-utils openjdk-17-jre-headless
# DEPENDS       :https://github.com/validator/validator
# DEPENDS       :apt-get install --no-install-recommends dbus-x11 chromium chromium-sandbox imagemagick

set -e

DIRECTORY="$(date "+%s")"
mkdir "${DIRECTORY}"
cd "${DIRECTORY}"

wget --no-verbose --max-redirect=0 "https://EXAMPLE.COM/.well-known/safe-upgrade/urls"

while read -r URL; do
    SLUG="$(echo "${URL}" | iconv -t "ascii//TRANSLIT" | sed -e 's#[^0-9A-Za-z-]#_#g')"
    # Add --post-data="form-name=contact" to make POST requests to bypass caches
    wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0" \
        --max-redirect=0 -q -S -O - "${URL}" 1>"${SLUG}.html" 2>"${SLUG}.headers"
    grep -q -F 'HTTP/1.1 200 OK' "${SLUG}.headers"
    grep -q -F -i '</html>' "${SLUG}.html"
    # Remove always changing elements
    sed -i -e 's#nonce":"[0-9a-f]\{10\}"#nonce":"NONCE"#' "${SLUG}.html"
    sed -i -e 's#type="[0-9a-f]\{24\}-text/javascript"#type="ROCKET_LOADER_ID-text/javascript"#' "${SLUG}.html"
    java -jar vnu.jar --errors-only --filterpattern 'Element “div” not allowed.*' "${SLUG}.html"
    dos2unix -q -k -n "${SLUG}.html" "${SLUG}.html.lf"
    expand --tabs=4 "${SLUG}.html.lf" >"${SLUG}.html.lf.space"
    xmlstarlet fo --html --recover "${SLUG}.html.lf.space" >"${SLUG}.xml.original" 2>/dev/null
    # Remove always changing elements
    #xmlstarlet ed --update '//script[contains(@type,"-text/javascript")]/@type' -v 'ROCKET_LOADER_ID-text/javascript'
    xmllint --format --output "${SLUG}.xml" "${SLUG}.xml.original"
    sed -e "0,/<head>/{s#<head>#&<base href='${URL}'>#}" "${SLUG}.html" >"${SLUG}.base.html"
    chromium --disable-crash-reporter --disable-audio-output --disable-gpu --single-process \
        --headless --screenshot=image.png --window-size=1366,10000 "${SLUG}.base.html"
done <urls

ls -1 -t -r ./*.xml
