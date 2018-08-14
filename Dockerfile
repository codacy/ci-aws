FROM alpine:3.7

LABEL maintainer="Daniel Reigada (dreigada) <daniel@codacy.com>"

RUN apk add --no-cache \
	bash \
	ca-certificates \
	curl \
	git \
	gzip \
	jq \
	openssh \
	tar \
	wget \
    python3 && \
    pip3 install --upgrade pip setuptools && \
    pip3 --no-cache-dir install awscli && \
    rm -rf /var/cache/apk/*

WORKDIR /root/project
