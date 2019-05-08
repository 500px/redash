FROM 500px/base:2.0.0
MAINTAINER platform <platform@500px.com>
WORKDIR /go/src/github.com/500px/redash

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
        curl \
        bc \
        apt-transport-https \
        git \
        gcc \
    && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/man/* && rm -rf /usr/share/doc/*

EXPOSE 8085

COPY . .

RUN make build test \
    && apt-get purge -y \
    git \
    bc \
    gcc

CMD ["./server"]
