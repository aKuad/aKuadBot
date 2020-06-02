#!/usr/bin/python

# Import
import time
import json
from websocket import create_connection
import subprocess
import os
import sys

args = sys.argv
if len(args) == 1:
  print("No argument")
  sys.exit(1)
if len(args) != 2:
  print("WS-Go.py: Incorrect argument")
  sys.exit(1)

stat_botToken = args[1]

data_sendIdentify = {
  "op": 2,
  "d": {
    "token": stat_botToken,
    "properties": {
      "$os": "linux",
      "$browser": "python",
      "$device": "fish"
    }
  },
  "s": None,
  "t": None
}

data_sendResume = {
  "op": 6,
  "d": {
    "token": stat_botToken,
    "session_id": 0,
    "seq": 0
  }
}

data_sendHb = {
  "op": 1,
  "d": 0
}

if __name__ == "__main__":
  # Data standby
  stat_srcDirPath = os.path.dirname(os.path.abspath(__file__))
  stat_cnvSh = os.path.join(stat_srcDirPath, "JSON-Cnv.sh")

  # Connect
  print("=== Connecting ===")
  ws = create_connection("wss://gateway.discord.gg?v=6&encoding=json")
  data_recvHello = ws.recv()
  data_recvLoadsHello = json.loads(data_recvHello)
  file = open(os.path.join(stat_srcDirPath, "log/01_hello.log"), "w")
  file.write(data_recvHello)
  file.close()
  print("** Connection result printed to '01_hello.log'")
  subprocess.check_call(["sh", stat_cnvSh, os.path.join(stat_srcDirPath, "log/01_hello.log")])


  # Identify
  ## Send
  print("=== Identify ===")
  ws.send(json.dumps(data_sendIdentify))
  file = open(os.path.join(stat_srcDirPath, "log/02_identify-send.log"), "w")
  file.write(json.dumps(data_sendIdentify))
  file.close()
  print("** Identify send printed to '02_identify-send.log'")
  subprocess.check_call(["sh", stat_cnvSh, os.path.join(stat_srcDirPath, "log/02_identify-send.log")])

  ## Recv
  data_recvReady=ws.recv()
  data_recvLoadsReady = json.loads(data_recvReady)
  file = open(os.path.join(stat_srcDirPath, "log/03_identify-recv.log"), "w")
  file.write(data_recvReady)
  file.close()
  print("** Identify recv printed to '03_identify-recv.log'")
  subprocess.check_call(["sh", stat_cnvSh, os.path.join(stat_srcDirPath, "log/03_identify-recv.log")])


  # Get session_id
  print("=== Session ID ===")
  data_sessionId = data_recvLoadsReady["d"]["session_id"]
  data_sendResume["d"]["session_id"] = data_sessionId
  print("Session ID: " + str(data_sessionId))


  # Get sequence num
  data_sequenceNum = data_recvLoadsReady["s"]
  data_sendResume["d"]["seq"] = data_sequenceNum


  # Heart beat send
  print("=== Heart beat sending ===")
  hb_interval = data_recvLoadsHello["d"]["heartbeat_interval"]
  print("Heart beat interval: " + str(hb_interval))
  data_sendHb["d"] = data_sequenceNum

  try:
    while True:
      try:
        while True:
          ws.send(json.dumps(data_sendHb))
          data_recvHb = ws.recv()
          data_recvLoadsHb = json.loads(data_recvHb)
          if data_recvLoadsHb["s"] != None:
            print("Received data  seq:" + str(data_recvLoadsHb["s"]))
            data_sendResume["d"]["session_id"] = data_sessionId
            data_sendResume["d"]["seq"] = data_recvLoadsHb["s"]
            file = open(os.path.join(os.path.dirname(stat_srcDirPath), "seq" + str(data_recvLoadsHb["s"]) + ".json"), "w")
            file.write(data_recvHb)
            file.close()
          time.sleep(0.2)
      except:
        ws.close()
        print("Web socket closed. Restart")
        ws = create_connection("wss://gateway.discord.gg?v=6&encoding=json")
        ws.send(json.dumps(data_sendResume))
        print("Resumed")
  except:
    ws.close()
    print("Web socket closed. Program quit.")
