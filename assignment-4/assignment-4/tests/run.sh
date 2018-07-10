#!/bin/bash

lua receiver.lua localhost 1883 &

for i in `seq 1 100`; do
    echo "Starting sender-"$i
    lua sender.lua localhost 1883 $i &
done
