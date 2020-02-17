FROM golang:latest as builder

RUN apt-get update && apt-get dist-upgrade -qy

ENV GOOS=linux GOARCH=arm64

RUN go get -u -v google.golang.org/grpc && \
    git clone https://www.github.com/dgraph-io/dgraph/ && \
    cd dgraph && \
    make install && \
    mkdir -p /dist/bin && \
    mkdir -p /dist/tmp  && \
    mv ${GOPATH}/bin/**/dgraph /dist/bin/dgraph

FROM scratch as dgraph
COPY --from=builder /dist /
ENV PATH=$PATH:/bin/

# Dgraph node type | gRPC-internal | gRPC-external | HTTP-external
#             zero |          5080 |             - |          6080
#            alpha |          7080 |          9080 |          8080
#            ratel |             - |             - |          8000
EXPOSE 5080 6080 7080 8080 8000 9080