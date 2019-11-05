#!/bin/bash

docker build -t dnsmasq:0.1 .

docker save dnsmasq:0.1 | gzip > ../../dnsmasq-0.1.tar.gz
