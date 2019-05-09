FROM alpine:latest

LABEL maintainer="arnstein@arnstein.comedian"
LABEL "The beginnging of a boost img"

RUN apk upgrade \
    && apk add p7zip

WORKDIR /usr/arnstein

ADD https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.7z .

RUN 7z x -aoa boost_1_70_0.7z

CMD [ "sh" ]
