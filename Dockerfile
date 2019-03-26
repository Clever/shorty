FROM debian:stretch

# put all static files in /var/www
RUN mkdir -p /var/www/shorty/static
ADD static /var/www/shorty/static
WORKDIR /var/www/shorty

COPY bin/shorty /usr/bin/shorty
CMD ["shorty"]
