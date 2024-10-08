#!/bin/bash
rm -f ./epub/content/*.html
cd html
for file in *.html; do
    iconv -f gbk -t utf8 $file > ../epub/content/$file
    echo $file
done
