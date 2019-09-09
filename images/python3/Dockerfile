FROM ubuntu:latest

# for ubuntu
RUN apt update \
    && apt install -y bash \
    && apt install -y python3 \
    && apt install -y nano

# for Alpine
# RUN apk update \
#     && apk add bash \
#     && apk add python3 \
#     && apk add nano

WORKDIR ./usr/ak

CMD ["bash"]