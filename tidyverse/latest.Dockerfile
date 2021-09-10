FROM registry.gitlab.b-data.ch/r/r-ver:4.1.1

LABEL org.opencontainers.image.source="https://gitlab.b-data.ch/r/yads"

ARG DEBIAN_FRONTEND=noninteractive
ARG PANDOC_VERSION=2.14.2

ENV PANDOC_VERSION=${PANDOC_VERSION}

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    curl \
    libcairo2-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libmariadbd-dev \
    libpq-dev \
    libsasl2-dev \
    libssh2-1-dev \
    libsqlite3-dev \
    libssl-dev \
    libtiff-dev \
    libxml2-dev \
    unixodbc-dev \
    wget \
  && install2.r --error BiocManager \
  && install2.r --error \
    --deps TRUE \
    --skipinstalled \
    tidyverse \
    dplyr \
    devtools \
    formatR \
    selectr \
    caTools \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb \
  && rm pandoc-${PANDOC_VERSION}-1-$(dpkg --print-architecture).deb
