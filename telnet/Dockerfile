FROM ubuntu

RUN apt update \
 && apt install -y telnet git \
 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT telnet
