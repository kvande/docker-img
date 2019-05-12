FROM alpine:latest

LABEL maintainer="jalla@balla.com"
LABEL description="The beginnging of a boost img"

EXPOSE 8085

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

WORKDIR /usr/ping-pong/boost_1_70_0

RUN ./bootstrap.sh
RUN ./b2 toolset=gcc stage

WORKDIR /usr/arnstein

# ./bootstrap.sh --prefix=${SHYFT_DEPENDENCIES_DIR}
#     boost_packages="--with-system --with-filesystem --with-date_time --with-python --with-serialization"
#     ./b2 -j2 -d0 link=shared variant=release threading=multi ${boost_packages}
#     ./b2 -j2 -d0 install threading=multi link=shared ${boost_packages}



CMD [ "sh" ]
