#!/usr/bin/python

# Library import
import sys


# Argument check
args = sys.argv
if len(args) == 4:
  i = 0
  try:
    ret = [int(args[1]), int(args[2]), int(args[3])]
  except:
    print("Failed to read the decimal code")
    sys.exit(1)
  while i <= 2:
    if ret[i] < 0:
      ret[i] = 0
    elif 0xFF < ret[i]:
      ret[i] = 0xFF
    i += 1

  print(str(ret[0]) + " " + str(ret[1]) + " " + str(ret[2]))
  sys.exit(0)

if len(args) == 1:
  print("Empty code")
  sys.exit(1)

if len(args) != 2:
  print("Incorrect code")
  sys.exit(1)


# Code decoding
## String read as hex
try:
  codeIn = int(args[1], 16)
except:
  print("Failed to read the hex color code")
  sys.exit(1)

## Number adjust
if codeIn > 0xFFFFFF:
  codeIn = 0xFFFFFF
elif codeIn < 0:
  codeIn = 0

## Number split
red = codeIn / 0x10000
gre = (codeIn / 0x100) - (red * 0x100)
blu = codeIn - (red * 0x10000) - (gre * 0x100)


# Result print
print(str(red) + " " + str(gre) + " " + str(blu))
