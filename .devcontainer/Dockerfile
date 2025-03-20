FROM mcr.microsoft.com/devcontainers/base:ubuntu

COPY build.sh .

RUN ./build.sh && rm ./build.sh

ENV GOROOT="/usr/local/go"
ENV GOBIN=${GOROOT}/bin
ENV PATH=${PATH}:${GOBIN}
