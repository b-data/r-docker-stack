FROM registry.gitlab.b-data.ch/r/r-ver:4.1.0

LABEL org.label-schema.vcs-url="https://gitlab.b-data.ch/r/yads"

ARG DEBIAN_FRONTEND=noninteractive
ARG PANDOC_VERSION

ENV PANDOC_VERSION=${PANDOC_VERSION:-2.14.1}

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    curl \
    libcairo2-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libmariadbclient-dev \
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
  # Install patched version or RPostgreSQL
  # Source: https://gitlab.b-data.ch/benz0li/rpostgresql
  && install2.r --error DBI \
  && curl -sSL https://gitlab.b-data.ch/benz0li/rpostgresql/-/package_files/6/download \
    -o RPostgreSQL_0.6-2.tar.gz \
  && R CMD INSTALL RPostgreSQL_0.6-2.tar.gz \
  && rm RPostgreSQL_0.6-2.tar.gz \
  # Install other packages in regular fashion
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
