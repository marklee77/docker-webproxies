FROM ubuntu:trusty
MAINTAINER Mark Stillwell <mark@stillwell.me>

# fixme: get i2p repo... tor repo? privoxy?
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -y install \
        curl \
        privoxy \
        squid3 \
        squidguard \
        supervisor \
        tor && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*


#WORKDIR /srv/supervisord

#COPY run.sh ./run.sh
#COPY supervisord.conf ./supervisord.conf

#RUN chown -R namecoin:namecoin . && \
#    chmod 755 ./run.sh && \
#    chmod 644 ./supervisord.conf

#VOLUME /srv/supervisord /var/cache

#EXPOSE 3128 3129 9050 9053/udp

#CMD ["/srv/supervisord/run.sh"]
