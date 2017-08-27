#!/bin/bash
set -e
src=$1
convert -resize 1920x1920 $src $src.big.jpg
convert -resize 970x970 $src $src.970.jpg
convert -resize 150x150 $src $src.150.jpg
rename '.jpg.' '.' $src.*
