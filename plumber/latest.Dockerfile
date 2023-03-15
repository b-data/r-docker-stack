ARG BUILD_ON_IMAGE=glcr.b-data.ch/r/ver
ARG R_VERSION

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    BUILD_DATE=${BUILD_START}

WORKDIR /usr/src

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    cmake \
    libcurl4-openssl-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libsodium-dev \
    libssl-dev \
    libudunits2-dev \
    libxml2-dev \
    sqlite3 \
    zlib1g-dev \
  ## sf: Installation fails on Debian 11 (bullseye) for v1.0-10
  ## https://github.com/r-spatial/sf/issues/2118
    curl \
  && install2.r --error -n $NCPUS \
    classInt \
    DBI \
    magrittr \
    Rcpp \
    s2 \
    units \
  && curl -sLO https://cran.r-project.org/src/contrib/Archive/sf/sf_1.0-9.tar.gz \
  && R CMD INSTALL sf_1.0-9.tar.gz \
  && rm sf_1.0-9.tar.gz \
  ## Install plumber
  && install2.r --error --deps TRUE -n $NCPUS plumber \
  ## Set up endpoint
  && echo '#* Return "hello world"\n#* @get /hello\nfunction() {\n  "hello world"\n}' > hello-world.R \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 8000

## Configure container startup
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); pr$run(host = '0.0.0.0', port = 8000)"]
CMD ["hello-world.R"]
