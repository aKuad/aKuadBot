#!/bin/sh

# Variables define
if [ -e "token.txt" ]; then
  stat_token=$(cat token.txt)
else
  echo "'token.txt' not found"
  exit 1
fi

data_tjson=""
data_mes=""
comm_name=""
comm_arg=""


# Connect WebSocket
mate-terminal -e "./src-core/WS-Go.py $stat_token"


# Loop of JSON reading
echo "Started to searching JSON"
while true; do
  # Search JSON exist
  ls -l seq*.json > /dev/null 2>&1
  stat_ret=$?

  # When JSON exist
  if [ $stat_ret = 0 ]; then
    # Loop for JSON files
    for f in seq*.json; do
      # Get JSON file data
      data_tjson=$(cat $f)
      data_tjson=$(echo $data_tjson)
      echo "T: $(echo $data_tjson | jq -r .t)"

      # When MESSAGE_CREATE
      if [ "$(echo $data_tjson | jq -r .t)" = "MESSAGE_CREATE" ]; then
        # Message get
        data_mes=$(echo $data_tjson | jq -r .d.content)

        # When it is command for aKuadBot
        if [ "${data_mes%% *}" = "k$" ]; then
          data_mes="${data_mes#k$ }"
          echo "Command receive '$data_mes'"

          comm_name=${data_mes%% *}
          comm_arg=${data_mes#* }

          # Command check
          #if [ "$comm_name" = "" ]; then
          #  echo "Empty"
          if [ "$comm_name" = "help" ]; then
            mv $f ./src-func/help/recv.json
            ./src-func/help/help.sh $stat_token "recv.json"
          elif [ "$comm_name" = "hello" ]; then
            mv $f ./src-func/hello/recv.json
            ./src-func/hello/hello.sh $stat_token "recv.json"
          elif [ "$comm_name" = "colorbmp" ]; then
            mv $f ./src-func/colorbmp/recv.json
            ./src-func/colorbmp/colorbmp.sh $stat_token "recv.json" "$comm_arg"
          else
            rm $f
          fi
        else
          rm $f
        fi
      else
        rm $f
      fi
    done
  fi
  sleep 0.5
done
