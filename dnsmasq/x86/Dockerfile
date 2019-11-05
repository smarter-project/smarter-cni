FROM alpine:3.7

RUN apk update \
  && apk add --no-cache libstdc++ \
  && apk add --no-cache --virtual .build-deps musl-dev \
        binutils-gold \
        gcc \
        libgcc \
        linux-headers \
        make \
        git \
  && mkdir -p /usr/src \
  && cd /usr/src \
  && git clone git://thekelleys.org.uk/dnsmasq.git \
  && cd /usr/src/dnsmasq \
  && make install \
  && cd /usr \
  && apk del .build-deps \
        gcc \
        linux-headers \
        make \
        git \
  && rm -rf /usr/src

WORKDIR  /usr/src/dnsmasq

COPY dnsmasq.conf /etc

CMD [ "/usr/local/sbin/dnsmasq", "-k" ]
