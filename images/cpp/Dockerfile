FROM ubuntu:18.04

# add disco main to retrive 'newest' cmake version
RUN apt update \
    && apt -y install software-properties-common \
    && apt-add-repository 'deb http://archive.ubuntu.com/ubuntu/ disco main' \
    && apt -y install cmake \
    && apt -y install g++ \
    && apt -y install gdb
    

WORKDIR /usr/ak