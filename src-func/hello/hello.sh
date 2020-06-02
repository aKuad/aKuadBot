#!/bin/bash

# Variables define
stat_srcDir=$(cd $(dirname $0); pwd)

arg_token="$1"
arg_raw="$(cat $stat_srcDir/$2)"
rm $stat_srcDir/$2


# Argument check
if [ "$arg_token" = "" ] || [ "$arg_raw" = "" ]; then
  echo "Not sufficient arguments"
  exit 1
fi

arg_chId="$(echo $arg_raw | jq -r .d.channel_id)"
arg_uName="$(echo $arg_raw | jq -r .d.author.username)"
arg_uId="$(echo $arg_raw | jq -r .d.author.id)"


# Function define
function sendMes() {
  curl -X POST -s \
  -H "Authorization: Bot $arg_token" \
  -H 'Content-Type: application/json' \
  -d "{\"content\": \"$1\", \"tts\": false}" \
  https://discordapp.com/api/channels/$arg_chId/messages > $stat_srcDir/result.json
}


# Message send
sendMes "Hello, $arg_uName <@$arg_uId>"
