FROM codacy/ci-base

LABEL maintainer="Daniel Reigada (dreigada) <daniel@codacy.com>"

RUN apk add --no-cache \
    python3 && \
    pip3 install --upgrade pip setuptools && \
    pip3 --no-cache-dir install awscli==1.15.77 && \
    rm -rf /var/cache/apk/*

WORKDIR /root/project
