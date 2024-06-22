# prebuilt image at:
# https://hub.docker.com/averyfreeman/zfs-kernel-ubuntu:latest
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND="noninteractive"
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
RUN apt-get update 
RUN apt-get upgrade -y 
RUN apt-get install -y apt-utils
RUN apt-get install -y language-pack-en-base

ENV LC_ALL=en_US.UTF-8
ENV TZ='America/Los_Angeles'
ENV LC_CTYPE en_US.UTF-8

WORKDIR /app
RUN mkdir /app/build

COPY ./bootstrap.sh /app/bootstrap.sh
COPY ./build.sh /app/build.sh
COPY ./.config /app/.config

RUN /app/bootstrap.sh

COPY ./run.sh /run.sh

ENTRYPOINT /run.sh