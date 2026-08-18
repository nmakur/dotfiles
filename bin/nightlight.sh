#!/bin/bash
# ~/.local/bin/nightlight.sh

if pkill -0 gammastep 2>/dev/null; then
  pkill gammastep
else
  gammastep -O 4000 &
fi
