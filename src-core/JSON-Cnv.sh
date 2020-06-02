#!/bin/sh

if [ -e "$1" ]; then
  sName=${1%.*}
  cat $1 | jq . > $sName.json
  rm $1
fi

