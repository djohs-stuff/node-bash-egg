FROM ubuntu:20.04@sha256:ed4a42283d9943135ed87d4ee34e542f7f5ad9ecf2f244870e23122f703f91c2
ARG DEBIAN_FRONTEND=noninteractive

ARG NODE_VERSION
ARG X_URL=https://deb.nodesource.com/setup_$NODE_VERSION.x
ARG BUN_VERSION=v1.0.11

RUN apt update && \
    apt install -y curl software-properties-common default-jre locales git unzip libnss3 && \
    useradd -d /home/container -m container

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN curl -sL $X_URL | bash - && \
    apt install -y nodejs g++ build-essential ffmpeg
RUN npm i -g pm2

# Install yarn
RUN apt remove cmdtest
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install yarn

# Install bun
RUN curl -fLO https://github.com/oven-sh/bun/releases/download/bun-${BUN_VERSION}/bun-linux-x64-baseline.zip && \
    unzip bun-linux-x64-baseline.zip && \
    mv bun-linux-x64-baseline/bun /usr/local/bin/bun && \
    rm bun-linux-x64-baseline.zip

USER container
ENV USER container
ENV HOME /home/container

WORKDIR /home/container

COPY ./nodejs.entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
