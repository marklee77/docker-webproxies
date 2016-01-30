FROM phusion/baseimage
MAINTAINER Mark Stillwell <mark@stillwell.me>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-add-repository \
        "deb http://deb.torproject.org/torproject.org $(lsb_release -sc) main" && \
    gpg --keyserver keys.gnupg.net --recv 886DDD89 && \
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add - && \
    apt-add-repository ppa:i2p-maintainers/i2p && \
    apt-get update && \
    apt-get -y install \
        curl \
        i2p \
        privoxy \
        squid3 \
        squidguard \
        deb.torproject.org-keyring \
        tor && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY files/etc/squid3/squid.conf /etc/squid3/squid.conf
COPY files/etc/squidguard/squidGuard.conf /etc/squidguard/squidGuard.conf
COPY files/etc/squidguard/blacklisted.html /etc/squidguard/blacklisted.html
RUN chmod 644 /etc/squid3/squid.conf && \
    chmod 644 /etc/squidguard/squidGuard.conf && \
    chmod 644 /etc/squidguard/blacklisted.html && \
    cd /var/lib/squidguard/db && \
    curl -s http://www.shallalist.de/Downloads/shallalist.tar.gz | tar xzf - && \
    /usr/bin/squidGuard -C all && \
    chown -R proxy:proxy /var/lib/squidguard/db && \
    mkdir /etc/service/squid3 && \
    echo "#!/bin/sh\n/usr/sbin/squid3 -z\nexec /usr/sbin/squid3 -NYC" \
        > /etc/service/squid3/run && \
    chmod 755 /etc/service/squid3/run

COPY files/etc/privoxy/config /etc/privoxy/config
COPY files/etc/privoxy/user.action /etc/privoxy/user.action
RUN chmod 644 /etc/privoxy/config /etc/privoxy/user.action && \
    mkdir /etc/service/privoxy && \
    echo \
        "#!/bin/sh\nexec /usr/sbin/privoxy --no-daemon --user privoxy /etc/privoxy/config" \
        > /etc/service/privoxy/run && \
    chmod 755 /etc/service/privoxy/run

COPY files/etc/tor/torrc /etc/tor/torrc
RUN chmod 755 /etc/tor/torrc && \
    mkdir -p /var/run/tor && \
    chown debian-tor:debian-tor /var/run/tor && \
    chmod 700 /var/run/tor && \
    mkdir /etc/service/tor && \
    echo "#!/bin/sh\nexec /usr/bin/tor --defaults-torrc /usr/share/tor/tor-service-defaults-torrc" \
        > /etc/service/tor/run && \
    chmod 755 /etc/service/tor/run

COPY files/var/lib/i2p/i2p-config /var/lib/i2p/i2p-config
RUN chown -R i2psvc:i2psvc /var/lib/i2p && \
    mkdir /etc/service/i2p && \
    echo "#!/bin/sh\nexec /sbin/setuser i2psvc /usr/bin/i2prouter console" \
        > /etc/service/i2p/run && \
    chmod 755 /etc/service/i2p/run

VOLUME /var/cache /var/lib /var/log /var/run

EXPOSE 3128 3129 4444 4445 8118 9050 9051 9053/udp
