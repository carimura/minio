FROM alpine:3.6

MAINTAINER Minio Inc <dev@minio.io>

ENV GOPATH /go
ENV PATH $PATH:$GOPATH/bin
ENV CGO_ENABLED 0

WORKDIR /go/src/github.com/minio/

COPY dockerscripts/docker-entrypoint.sh dockerscripts/healthcheck.sh /usr/bin/

RUN  \
     apk add --no-cache ca-certificates curl && \
     apk add --no-cache --virtual .build-deps git go musl-dev && \
     echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
     go get -v -d github.com/minio/minio && \
     cd /go/src/github.com/minio/minio && \
     go install -v -ldflags "$(go run buildscripts/gen-ldflags.go)" && \
     rm -rf /go/pkg /go/src /usr/local/go && apk del .build-deps

EXPOSE 9000

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/export"]

HEALTHCHECK --interval=30s --timeout=5s \
    CMD /usr/bin/healthcheck.sh

CMD ["minio"]
