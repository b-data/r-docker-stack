FROM registry.gitlab.b-data.ch/r/r-ver:4.0.2

LABEL org.label-schema.vcs-url="https://gitlab.b-data.ch/r/yads"

ARG PANDOC_VERSION

ENV PANDOC_VERSION=${PANDOC_VERSION:-2.9}

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    curl \
    libcairo2-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libmariadbclient-dev \
    libmariadbd-dev \
    libpq-dev \
    libsasl2-dev \
    libssh2-1-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    unixodbc-dev \
    wget \
  && install2.r --error BiocManager \
  && install2.r --error \
    --deps TRUE \
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
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-amd64.deb \
  && rm pandoc-${PANDOC_VERSION}-1-amd64.deb
