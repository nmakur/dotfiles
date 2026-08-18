#!/bin/bash
# ~/.local/bin/texcc.sh

latexmk -pdf $1 && latexmk -c $1
