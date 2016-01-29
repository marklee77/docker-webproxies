FROM ubuntu:trusty
MAINTAINER Mark Stillwell <mark@stillwell.me>

# fixme: get i2p repo... tor repo? privoxy?
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install software-properties-common && \
    apt-add-repository ppa:i2p-maintainers/i2p && \
    apt-get update && \
    apt-get -y install \
        i2p \
        privoxy \
        squid3 \
        squidguard \
        supervisor \
        tor && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

WORKDIR /srv/supervisord

COPY supervisord.conf ./supervisord.conf
RUN chmod 644 ./supervisord.conf

COPY etc/tor/torrc /etc/tor/torrc
RUN chmod 755 /etc/tor/torrc && \
    mkdir -p /var/run/tor && \
    chown debian-tor:debian-tor /var/run/tor && \
    chmod 700 /var/run/tor

VOLUME /srv/supervisord /var/cache /var/run

EXPOSE 3128 3129 4444 4445 8118 9050 9051 9053/udp

CMD ["/usr/bin/supervisord", "-n", "-c", "./supervisord.conf"]
