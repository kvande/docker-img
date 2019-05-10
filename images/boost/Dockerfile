FROM alpine:latest

LABEL maintainer="jalla@balla.com"
LABEL description="The beginnging of a boost img"

RUN apk upgrade \
    && apk add p7zip \
    && apk add bash \
    && apk add tree \
    && apk add build-base \
    && apk add linux-headers \
    && apk add cmake

WORKDIR /usr/arnstein

ADD https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.7z .

RUN 7z x -aoa boost_1_70_0.7z

WORKDIR /usr/arnstein/boost_1_70_0

RUN ./bootstrap.sh
RUN ./b2 toolset=gcc stage

CMD [ "sh" ]
