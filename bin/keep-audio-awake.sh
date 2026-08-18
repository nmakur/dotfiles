#!/bin/bash

sleep 3
while true; do
  play -q -r 48000 -n -t alsa -b 16 -c 2 synth whitenoise vol 0.001 repeat -
  sleep 1
done
