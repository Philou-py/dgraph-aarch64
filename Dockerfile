ARG GOLANG=1.13.8-buster
FROM golang:${GOLANG} as builder

RUN apt-get update && apt-get dist-upgrade -qy

ENV GOOS=linux GOARCH=arm64 CGO_ENABLED=0
RUN go get -u -v google.golang.org/grpc && \
    git clone https://www.github.com/dgraph-io/dgraph/ && \
    cd dgraph && \
    make install

RUN mkdir -p /dist/bin && \
    mkdir -p /dist/tmp && \
    mv ${GOPATH}/bin/dgraph /dist/bin/dgraph

FROM alpine:latest as dgraph
COPY --from=builder /dist /
ENV PATH=$PATH:/bin/
RUN chmod +x /bin/dgraph && apk --update --no-cache add bash

# Dgraph node type | gRPC-internal | gRPC-external | HTTP-external
#             zero |          5080 |             - |          6080
#            alpha |          7080 |          9080 |          8080
#            ratel |             - |             - |          8000
EXPOSE 5080 6080 7080 8080 8000 9080
CMD ["/bin/dgraph", "version"]