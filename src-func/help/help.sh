#!/bin/bash

# Variables define
stat_srcDir=$(cd $(dirname $0); pwd)

arg_token="$1"
arg_raw="$(cat $stat_srcDir/$2)"
rm $stat_srcDir/$2

arg_chId="$(echo $arg_raw | jq -r .d.channel_id)"


# Argument check
if [ "$arg_token" = "" ] || [ "$arg_raw" = "" ]; then
  echo "Not sufficient arguments"
  exit 1
fi


# Function define
function sendEmbed() {
  curl -X POST -s \
  -H "Authorization: Bot $arg_token" \
  -H 'Content-Type: application/json' \
  -d "{\"content\": \"$1\", \"tts\": false, \"embed\": $2}" \
  https://discordapp.com/api/channels/$arg_chId/messages > $stat_srcDir/result.json
}


# Message send
var_embed='{
"description": "To see more help of command, type `<command> -help`.",
"fields": [
  {"name": "`k$ help`", "value": "Print available commands and simple description.", "inline": false},
  {"name": "`k$ hello`", "value": "Say hello and mention send user.", "inline": false},
  {"name": "`k$ colorbmp [options] <color code>`", "value": "Response a monochromatic image according to the color code.", "inline": false}
],
"type": "rich",
"color": 3289855,
"footer": {"text": "help - aKuadBot"}
}'

sendEmbed "Command list for aKuadBot" "$(echo $var_embed)"
