FROM codacy/ci-base:3.0.1

LABEL maintainer="Codacy <team@codacy.com>"

ENV PACKER_VERSION=1.3.2
ENV TERRAFORM_VERSION=1.1.9
ENV PACKER_SHA256SUM=5e51808299135fee7a2e664b09f401b5712b5ef18bd4bad5bc50f4dcd8b149a1
# Bumping helm minor version is a breaking change
ENV HELM_VERSION=v3.3.1
ENV HELM_SSM_VERSION=3.1.0
ENV HELM_PUSH_VERSION=0.9.0

ENV KUBECTL_VERSION=v1.19.2
ENV M4_VERSION=1.4.18-r2

ENV PYTHON3_VERSION=3.9.7-r4
ENV PIP_VERSION=22.0.4
ENV SETUPTOOLS_VERSION=59.1.0

ENV SOPS_VERSION=3.7.3-r1
ENV SSM_PARAMETER_MANAGER_VERSION=0.2.1

COPY requirements.pip .

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_SHA256SUMS ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip ./
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS ./

RUN apk add "sops=${SOPS_VERSION}" --no-cache --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ && \
    apk add --no-cache "python3=${PYTHON3_VERSION}" "m4=${M4_VERSION}" py3-pip&& \
    pip3 install --upgrade pip==${PIP_VERSION} setuptools==${SETUPTOOLS_VERSION} && \
    pip3 --no-cache-dir install -r requirements.pip --ignore-installed packaging&& \
    sed -i '/.*linux_amd64.zip/!d' packer_${PACKER_VERSION}_SHA256SUMS && \
    sha256sum -cs packer_${PACKER_VERSION}_SHA256SUMS && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && \
    sed -i '/.*linux_amd64.zip/!d' terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum -cs terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    curl "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -zxf - && \
    mv linux-amd64/helm /usr/local/bin/helm && \    
    chmod +x /usr/local/bin/helm && \
    helm plugin install https://github.com/codacy/helm-ssm/releases/download/${HELM_SSM_VERSION}/helm-ssm-linux.tgz && \
    helm plugin install https://github.com/chartmuseum/helm-push --version ${HELM_PUSH_VERSION} && \
    curl -Lo /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl && \
    curl -Lo /usr/local/bin/aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator" && \
    chmod +x /usr/local/bin/aws-iam-authenticator && \
    curl -L https://github.com/codacy/ssm-parameter-manager/releases/download/${SSM_PARAMETER_MANAGER_VERSION}/ssm-parameter-manager_linux_amd64 -o ssm-parameter-manager && \
    mv ssm-parameter-manager /usr/local/bin/ssm-parameter-manager && \
    chmod +x /usr/local/bin/ssm-parameter-manager && \
    rm -f packer_${PACKER_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm -rf /var/cache/apk/* \
    rm -rf -- *
