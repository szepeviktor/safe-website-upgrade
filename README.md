# Safe website upgrade

Make snapshots of the HTML output of a website before/after an upgrade.

## Purpose

Were you ever nervous while upgrading/updating
PHP interpreter, Redis server, Laravel framework, PHP package, WordPress core or plugin?

## Snapshot pages

Create snapshots in a timestamp-named directory.

1. Get list of pages - `wget https://example.com/.well-known/safe-upgrade/urls`
1. Download HTML pages and HTTP headers - `wget -qSO- 1>page.html 2>page.headers`
1. Check HTML pages - `grep '</html>'`
1. Find HTML errors - `java -jar vnu.jar --errors-only`
1. Fix line ends - `dos2unix`
1. Convert TAB characters - `expand --tabs=4`
1. Normalize to XML - `xmlstarlet fo --html --recover 2>/dev/null`
1. Remove always changing elements - `xmlstarlet ed --delete '//path'`
1. Reformat - `xmllint --format`
1. Screenshot - `chromium --headless --screenshot=image.png`

## Compare two snapshots

```bash
colordiff -rsu -x "*.headers" -x "*.html" -x "*.html.lf" -x "*.html.lf.space" -x "*.xml.original" $(ls -dtr [1-9]*/|tail -n 2)
compare -verbose -metric mae $(ls -tr [1-9]*/image.png|tail -n 2) diff01.png
```
