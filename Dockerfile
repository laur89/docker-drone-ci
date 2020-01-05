FROM nephatrine/alpine-s6:testing
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add \
   docker \
   git \
   sqlite \
 && rm -rf /var/cache/apk/*

RUN echo "====== COMPILE DRONE ======" \
 && apk add --virtual .build-drone build-base go \
 && cd /usr/src \
 && git clone https://github.com/drone/drone && cd drone \
 && go install -tags nolimit ./cmd/drone-server \
 && mv /root/go/bin/drone-server /usr/bin/ \
 && go install ./cmd/drone-agent \
 && mv /root/go/bin/drone-agent /usr/bin/ \
 && cd /usr/src \
 && git clone https://github.com/drone/drone-cli && cd drone-cli \
 && go install ./... \
 && mv /root/go/bin/drone /usr/bin/ \
 && cd /usr/src \
 && git clone https://github.com/drone-runners/drone-runner-exec && cd drone-runner-exec \
 && go build -o /usr/bin/drone-runner-exec \
 && cd /usr/src && rm -rf /root/go /usr/src/* \
 && apk del --purge .build-drone && rm -rf /var/cache/apk/*

EXPOSE 8080/tcp
COPY override /
