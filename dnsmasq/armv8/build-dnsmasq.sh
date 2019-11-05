#!/bin/bash

docker build -t arm64v8/dnsmasq:0.1 .

docker save arm64v8/dnsmasq:0.1 | gzip > ../../arm64v8_dnsmasq-0.1.tar.gz
