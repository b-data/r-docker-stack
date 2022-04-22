FROM registry.gitlab.b-data.ch/r/r-ver:4.2.0

LABEL org.opencontainers.image.source="https://gitlab.b-data.ch/r/yads"

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive
ARG PANDOC_VERSION=2.18

ENV PANDOC_VERSION=${PANDOC_VERSION}

RUN dpkgArch="$(dpkg --print-architecture)" \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    cmake \
    curl \
    libcairo2-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libmariadb-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libssl-dev \
    libtiff-dev \
    libxml2-dev \
    libxtst6 \
    unixodbc-dev \
    wget \
  && install2.r --error -n $NCPUS BiocManager \
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    tidyverse \
    dplyr \
    devtools \
    formatR \
  ## dplyr database backends
  && install2.r --error --skipinstalled -n $NCPUS \
    arrow \
    duckdb \
    fst \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && rm pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb
