#!/bin/bash

docker build -t arm32v6/dnsmasq:0.1 .

docker save arm32v6/dnsmasq:0.1 | gzip >  ../../arm32v6_dnsmasq-0.1.tar.gz
