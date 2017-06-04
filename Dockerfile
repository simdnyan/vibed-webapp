FROM simdnyan/vibed:0.7.31 AS builder
MAINTAINER Yoshinori SHIMADA <simd.nyan@gmail.com>

COPY . /src
RUN dub build --build=release


FROM debian:jessie-slim

RUN apt-get update && apt-get install -y libevent-dev \
 && apt-get upgrade -y && apt-get clean && rm -rf /var/cache/apt /var/lib/apt/lists/*

EXPOSE 8080
WORKDIR src
COPY --from=builder /src/vibed-webapp /usr/local/bin/
COPY vibed-webapp.yaml /etc/

CMD ["vibed-webapp", "-c", "/etc/vibed-webapp.yaml"]
