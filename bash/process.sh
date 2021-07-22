#!/bin/bash -x
cd ~/Downloads

updir --sync ./stuff,/stuff
dedupdir -r ./stuff
find ./stuff -mindepth 2 -type f -exec mogrify -resize x1080\< {} \;
dedupdir -r ./stuff
rname -r -f ./stuff
updir --rebase local ./stuff,/stuff
