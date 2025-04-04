#!/bin/bash

# Compilation...

export TARGET="PICOLIBSDK"
export GRPDIR="picolibsdk"
export MEMMAP=""

export PICO_ROOT_PATH="/opt/PicoLibSDK"

$PICO_ROOT_PATH/_c1.sh "$1"
