# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Start from golang v1.11 base image
FROM golang:1.12-alpine

# Add Maintainer Info
LABEL maintainer="The OpenSentry Team"

RUN apk add --update --no-cache ca-certificates cmake make g++ openssl-dev git curl pkgconfig openssh libressl-dev

# RUN apt install -y libssl1.0.0
RUN git clone -b v1.7.4 https://github.com/neo4j-drivers/seabolt.git /seabolt

# invoke cmake build and install artifacts - default location is /usr/local
WORKDIR /seabolt/build

# CMAKE_INSTALL_LIBDIR=lib is a hack where we override default lib64 to lib to workaround a defect
# in our generated pkg-config file
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBDIR=lib .. && cmake --build . --target install

# Set the Current Working Directory inside the container
WORKDIR $GOPATH/src/github.com/opensentry

# Download projects and their dependencies
RUN go get -d -v github.com/opensentry/idp
RUN go get -d -v github.com/opensentry/aap
RUN go get -d -v github.com/opensentry/idpui
RUN go get -d -v github.com/opensentry/aapui
RUN go get -d -v github.com/opensentry/meui

# Development requires rerun
RUN go get github.com/ivpusic/rerun
# Cache for rerun
RUN mkdir /.cache
#RUN chown -R 1000 /.cache

# This container exposes port 443 to the docker network
EXPOSE 443

#USER 1000

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["rerun", "-a--serve"]
