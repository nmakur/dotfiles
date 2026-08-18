#!/bin/bash

current_status=$(playerctl loop)

if [ "$current_status" = "Track" ]; then
  playerctl loop playlist
else
  playerctl loop track
fi
