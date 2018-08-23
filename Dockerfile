FROM codacy/ci-base:2018.08.3

LABEL maintainer="Daniel Reigada (dreigada) <daniel@codacy.com>"

COPY requirements.pip .

RUN apk add --no-cache \
    python3 && \
    pip3 install --upgrade pip setuptools && \
    pip3 --no-cache-dir install -r requirements.pip && \
    rm -rf /var/cache/apk/*

WORKDIR /root/project
