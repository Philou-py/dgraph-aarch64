ARG GOLANG=latest
FROM golang:${GOLANG} as builder

RUN apt-get update && apt-get install -qy build-essential software-properties-common libjemalloc2 sudo

ENV CGO_ENABLED=0 GOOS=linux GOARCH=arm64
# Specify release branch, so that the architecture env variables take effect
RUN git clone --branch release/v21.03 https://github.com/dgraph-io/dgraph/ && \
    cd dgraph && \
    make install

RUN mkdir -p /dist/bin && \
    mkdir -p /dist/tmp && \
    mv ${GOPATH}/bin/dgraph /dist/bin/dgraph

FROM node:18-alpine as dgraph
COPY --from=builder /dist /
ENV PATH=$PATH:/bin/
RUN chmod +x /bin/dgraph && apk --update --no-cache add bash

# Dgraph node type | gRPC-internal | gRPC-external | HTTP-external
#             zero |          5080 |             - |          6080
#            alpha |          7080 |          9080 |          8080
#            ratel |             - |             - |          8000
EXPOSE 5080 6080 7080 8080 8000 9080
CMD ["/bin/dgraph", "version"]
