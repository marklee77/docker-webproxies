FROM phusion/baseimage
MAINTAINER Mark Stillwell <mark@stillwell.me>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install software-properties-common && \
    apt-add-repository ppa:i2p-maintainers/i2p && \
    apt-add-repository "deb http://deb.torproject.org/torproject.org $(lsb_release -sc) main" && \
    gpg --keyserver keys.gnupg.net --recv 886DDD89 && \
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add - && \
    apt-get update && \
    apt-get -y install \
        curl \
        i2p \
        privoxy \
        squid3 \
        squidguard \
        supervisor \
        deb.torproject.org-keyring \
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

COPY etc/squid3/squid.conf /etc/squid3/squid.conf
COPY etc/squidguard/squidGuard.conf /etc/squidguard/squidGuard.conf
COPY etc/squidguard/blacklisted.html /etc/squidguard/blacklisted.html
RUN  chmod 644 /etc/squid3/squid.conf && \
     chmod 644 /etc/squidguard/squidGuard.conf && \
     chmod 644 /etc/squidguard/blacklisted.html && \
     cd /var/lib/squidguard/db && \
     curl -s http://www.shallalist.de/Downloads/shallalist.tar.gz | tar xzf - && \
     /usr/bin/squidGuard -C all && \
     chown -R proxy:proxy /var/lib/squidguard/db

VOLUME /srv/supervisord /var/cache /var/run

EXPOSE 3128 3129 4444 4445 8118 9050 9051 9053/udp

CMD ["/usr/bin/supervisord", "-n", "-c", "./supervisord.conf"]
