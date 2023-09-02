# Safe website upgrade

## Snapshot pages

Timestamp-named directory.

1. Get list of pages - `wget https://example.com/.well-known/safe-upgrade/urls`
1. Download HTML pages and HTTP headers - `wget -qSO- 1>page.html 2>page.headers`
1. Check HTML pages - `grep -F '</html>'`
1. Validate HTML pages - `java -jar vnu.jar --Werror`
1. Fix line ends - `dos2unix -k`
1. Convert TAB characters - `expand --tabs=4`
1. Normalize to XML - `xmlstarlet fo --html --recover 2>/dev/null`
1. Remove always changing elements - `xmlstarlet ed --delete '//path'`
1. Reformat - `xmllint --format`

screenshot too

## Compare two snapshots

