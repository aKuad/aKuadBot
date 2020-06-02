#!/usr/bin/python

# Library import
import sys


# Argument check
args = sys.argv
if len(args) == 2:
  try:
    ret = int(args[1], 16)
  except:
    print("Failed to read the hex code")
    sys.exit(1)

  print(str(ret))
  sys.exit(0)

if len(args) == 1:
  print("Empty code")
  sys.exit(1)

if len(args) != 4:
  print("Incorrect code")
  sys.exit(1)


# Code decoding
## String read as dec
try:
  ret = 0
  ret += int(args[1]) * 0x10000
  ret += int(args[2]) * 0x100
  ret += int(args[3])
except:
  print("Failed to read the hex color code")
  sys.exit(1)


# Result print
print(format(ret, 'x'))
