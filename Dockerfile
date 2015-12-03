FROM debian:jessie
COPY bin/shorty /usr/bin/shorty
CMD ["shorty"]
