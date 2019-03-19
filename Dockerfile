FROM codacy/ci-base:1.0.1

LABEL maintainer="Codacy <team@codacy.com>"

ENV PACKER_VERSION=1.3.2
ENV PACKER_SHA256SUM=5e51808299135fee7a2e664b09f401b5712b5ef18bd4bad5bc50f4dcd8b149a1
ENV HELM_VERSION=v2.13.0
ENV KUBECTL_VERSION=v1.13.4

COPY requirements.pip .

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./

RUN apk add --no-cache python3 m4 && \
    pip3 install --upgrade pip setuptools && \
    pip3 --no-cache-dir install -r requirements.pip && \
    sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    curl -L "https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -zxf - && \
    mv linux-amd64/helm /usr/local/bin/helm && \    
    chmod +x /usr/local/bin/helm && \
    curl -L "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" > /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip && \
    rm -rf /var/cache/apk/* \
    rm -rf *
