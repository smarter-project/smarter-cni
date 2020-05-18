#!/bin/bash

echo "Mounted CNI plugins into standard locations"

while true; do :; done & kill -STOP $! && wait $!
