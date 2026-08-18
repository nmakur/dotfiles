#!/bin/bash

latexmk -pdf $1 && latexmk -c $1
