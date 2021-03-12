#!/bin/bash
cd ~/Downloads

echo "Resizing"
find ./stuff -mindepth 2 -type f -exec mogrify -resize x1080\< {} \;
echo "Deduping"
dedupdir -r ./stuff
echo "Renaming"
rname -r ./stuff
echo "Uploading"
updir ./stuff,/stuff
echo "Finished"