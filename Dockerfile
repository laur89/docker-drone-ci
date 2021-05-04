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
 && git -C /usr/src clone --depth=1 https://github.com/drone/drone && cd /usr/src/drone \
 && go install -tags nolimit ./cmd/drone-server \
 && mv /root/go/bin/drone-server /usr/bin/ \
 && go install ./cmd/drone-agent \
 && mv /root/go/bin/drone-agent /usr/bin/ \
 && git -C /usr/src clone --depth=1 https://github.com/drone/drone-cli && cd /usr/src/drone-cli \
 && go install ./... \
 && mv /root/go/bin/drone /usr/bin/ \
 && git -C /usr/src clone --depth=1 https://github.com/drone-runners/drone-runner-exec && cd /usr/src/drone-runner-exec \
 && go build -o /usr/bin/drone-runner-exec \
 && cd /usr/src && rm -rf /root/go /usr/src/* \
 && apk del --purge .build-drone && rm -rf /var/cache/apk/*

COPY override /

EXPOSE 8080/tcp