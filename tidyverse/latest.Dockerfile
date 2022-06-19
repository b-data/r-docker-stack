ARG R_VERSION=4.2.0

FROM registry.gitlab.b-data.ch/r/base:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    cmake \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libmariadb-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libtiff-dev \
    libxtst6 \
    unixodbc-dev \
  && install2.r --error --skipinstalled -n $NCPUS BiocManager \
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
  && rm -rf /var/lib/apt/lists/*
