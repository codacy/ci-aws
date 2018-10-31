FROM codacy/ci-base:2018.08.3

LABEL maintainer="Codacy <team@codacy.com>"

ENV PACKER_VERSION=1.3.2
ENV PACKER_SHA256SUM=5e51808299135fee7a2e664b09f401b5712b5ef18bd4bad5bc50f4dcd8b149a1

COPY requirements.pip .

RUN apk add --no-cache \
    python3 && \
    pip3 install --upgrade pip setuptools && \
    pip3 --no-cache-dir install -r requirements.pip && \
    rm -rf /var/cache/apk/* \
    rm -rf *

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS
RUN sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin
RUN rm -f packer_${PACKER_VERSION}_linux_amd64.zip
