#!/bin/bash

# Variables define
stat_srcDir=$(cd $(dirname $0); pwd)

arg_token="$1"
arg_raw="$(cat $stat_srcDir/$2)"
rm $stat_srcDir/$2
arg_options="${3#colorbmp*}"

arg_chId="$(echo $arg_raw | jq -r .d.channel_id)"

arg_helpPrint="0"
arg_cCode=""
arg_fType="png"
arg_size="100x100"
arg_opt="0"

var_typeRead="0"
var_sizeRead="0"
stat_comm=0


# Function define
function sendMes() {
  curl -X POST -s \
  -H "Authorization: Bot $arg_token" \
  -H 'Content-Type: application/json' \
  -d "{\"content\": \"$1\", \"tts\": false}" \
  https://discordapp.com/api/channels/$arg_chId/messages > $stat_srcDir/result.json
}

function sendEmbed() {
  curl -X POST -s \
  -H "Authorization: Bot $arg_token" \
  -H 'Content-Type: application/json' \
  -d "{\"content\": \"$1\", \"tts\": false, \"embed\": $2}" \
  https://discordapp.com/api/channels/$arg_chId/messages > $stat_srcDir/result.json
}

function sendImg() {
  curl -X POST -s \
  -H 'Authorization: Bot '$arg_token \
  -H 'Content-Type: multipart/form-data' \
  -F "content=$1" \
  -F "tts=false" \
  -F "file=@$2" \
  https://discordapp.com/api/channels/$arg_chId/messages > $stat_srcDir/result.json
}


# Option argument reading
for arg in $arg_options; do
  if [ "$var_typeRead" = "1" ]; then
    arg_fType=$arg
    var_typeRead="0"
    continue
  elif [ "$var_sizeRead" = "1" ]; then
    arg_size=$arg
    var_sizeRead="0"
    continue
  fi

  if [ "$arg" = "-help" ]; then
    arg_helpPrint="1"
  elif [ "$arg" = "-type" ]; then
    var_typeRead="1"
  elif [ "$arg" = "-size" ]; then
    var_sizeRead="1"
  elif [ "$arg" = "-opt" ]; then
    arg_opt="1"
  elif [ "$arg" != "${arg##*-}" ]; then
    sendMes "Undefined option '$arg'"
    exit 1;
  else
    arg_cCode="$arg_cCode $arg"
  fi

done


# Argument checking
## Helo print
if [ "$arg_helpPrint" = "1" ]; then
  var_embed='{
  "description": "Options of `colorbmp`",
  "fields": [
    {"name": "`-help`", "value": "Print help and exit.", "inline": false},
    {"name": "`-type <png or jpg (jpeg) or gif>`", "value": "Set output image file format.", "inline": false},
    {"name": "`-size WxH`", "value": "Set output image pixel size.", "inline": false},
    {"name": "`-opt`", "value": "Optimize output image (support for png and jpg)", "inline": false}
  ],
  "type": "rich",
  "color": "3289855",
  "footer": {"text": "colorbmp - aKuadBot"}
  }'

  sendEmbed "__**colorbmp**__\\nReturn a monochromatic image according to input color code.\\n\\nUseage: \`colorbmp [options] <color code>\`" "$(echo $var_embed)"
  exit 0
fi

## Argument convert to lower
arg_fType=$(echo $arg_fType | awk '{print tolower($0)}')
arg_size=$(echo $arg_size | awk '{print tolower($0)}')

## Size option check
if [ "$arg_size" = "${arg_size##*x}" ]; then
  sendMes "Invalid size"
  exit 1
fi

## RGB Code convert
arg_cCode=${arg_cCode##*#}
arg_cCode=$($stat_srcDir/hex2dec.py $arg_cCode)
stat_comm=$?
if [ "$stat_comm" != 0 ]; then
  sendMes "$arg_cCode"
  exit 1
fi
var_cCodeDec=$arg_cCode
var_cCodeHex=$($stat_srcDir/dec2hex.py $arg_cCode)


## File type
if [ "$arg_fType" != "png" ] && [ "$arg_fType" != "jpg" ] && [ "$arg_fType" != "jpeg" ] && [ "$arg_fType" != "gif" ]; then
  sendMes "Un supported file format '$arg_fType'"
  exit 1
fi


# Bitmap make
## Base copy and color write
cp $stat_srcDir/bmp-base.bin $stat_srcDir/color.bmp
$(cd $stat_srcDir; $stat_srcDir/bmp-write $arg_cCode)
stat_comm=$?
if [ "$stat_comm" != 0 ]; then
  sendMes "Failed to make a bitmap"
  rm $stat_srcDir/color.bmp
  exit 1
fi

## Convert
convert $stat_srcDir/color.bmp -resize $arg_size $stat_srcDir/color.$arg_fType
stat_comm=$?
if [ "$stat_comm" != 0 ]; then
  sendMes "Failed to convert a bitmap"
  rm $stat_srcDir/color.bmp
  exit 1
fi
rm $stat_srcDir/color.bmp

## Optimize
if [ "$arg_opt" = "1" ]; then
  if [ "$arg_fType" = "png" ]; then
    mv "$stat_srcDir/color.$arg_fType" "$stat_srcDir/tmp.$arg_fType"
    zopflipng -m "$stat_srcDir/tmp.$arg_fType" "$stat_srcDir/color.$arg_fType" > /dev/null 2>&1
    stat_comm=$?
    if [ "$stat_comm" != 0 ]; then
      sendMes "Failed to png optimize"
      exit 1
    fi
    rm "tmp.$arg_fType"
  elif [ "$arg_fType" = "jpg" ] || [ "$arg_fType" = "jpeg" ]; then
    mv "$stat_srcDir/color.$arg_fType" "$stat_srcDir/tmp.$arg_fType"
    mozcjpeg -quality 60 "$stat_srcDir/tmp.$arg_fType" | mozjpegtran -optimize -copy none > "$stat_srcDir/color.$arg_fType"
    stat_comm=$?
    if [ "$stat_comm" != 0 ]; then
      sendMes "Failed to jpeg optimize"
      exit 1
    fi
    rm "tmp.$arg_fType"
  fi
fi


# Response send
if [ $arg_opt = "1" ]; then
  var_optTF="True"
else
  var_optTF="False"
fi

var_embed='{
"description": "Bitmap status",
"fields": [
  {"name": "Code (hex)", "value": "`'$var_cCodeHex'`", "inline": true},
  {"name": "Code (dec)", "value": "`'$var_cCodeDec'`", "inline": true},
  {"name": "File type", "value": "'$arg_fType'", "inline": true},
  {"name": "Pixel size", "value": "`'$arg_size'`", "inline": true},
  {"name": "Optimize", "value": "'$var_optTF'", "inline": true}
],
"type": "rich",
"color": '$(python -c "print(int(\"$var_cCodeHex\", 16))")',
"footer": {"text": "colorbmp - aKuadBot"}
}'


#sendImg "" "$arg_cCode" "$stat_srcDir/color.$arg_fType"
sendEmbed "" "$(echo $var_embed)"
sendImg "" "$stat_srcDir/color.$arg_fType"


# Quit
rm $stat_srcDir/color.$arg_fType
exit 0
