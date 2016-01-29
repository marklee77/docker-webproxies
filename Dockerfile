FROM ubuntu:trusty
MAINTAINER Mark Stillwell <mark@stillwell.me>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install \
        squid3 \
        squidguard && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN useradd -m -s /bin/bash namecoin

WORKDIR /home/webproxies

COPY run.sh ./run.sh
COPY supervisord.conf ./supervisord.conf

RUN chown -R namecoin:namecoin . && \
    chmod 755 ./run.sh && \
    chmod 644 ./supervisord.conf

VOLUME /home/namecoin

EXPOSE 8053/udp 8336 9000

CMD ["/home/namecoin/run.sh"]
