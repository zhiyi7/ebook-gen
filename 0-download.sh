#!/bin/bash
rm -f ./html/*.html
cd html
aria2c -i ../urls.txt -x 16
