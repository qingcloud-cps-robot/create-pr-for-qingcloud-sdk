FROM ubuntu:latest
ENV  TZ=Asia/Shanghai
RUN  apt-get update
RUN  apt-get install -y git
RUN  apt-get install -y wget
RUN  apt-get install -y golang
RUN  apt-get install -y ruby-full
RUN  gem install rufo

COPY snips /usr/bin/snips
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
