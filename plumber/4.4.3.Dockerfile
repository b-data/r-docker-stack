ARG BUILD_ON_IMAGE=glcr.b-data.ch/r/ver
ARG R_VERSION=4.4.3

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
    curl \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libsodium-dev \
    libssl-dev \
    libudunits2-dev \
    libxml2-dev \
    sqlite3 \
    zlib1g-dev \
  ## Install plumber
  && install2.r --error --deps TRUE  -n $NCPUS plumber \
  ## Set up endpoint
  && echo '#* Return "hello world"\n#* @get /hello\nfunction() {\n  "hello world"\n}' > hello-world.R \
  ## Strip libraries of binary packages installed from PPPM
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && strip ${RLS}/*/libs/*.so \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 8000

## Configure container startup
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); pr$run(host = '0.0.0.0', port = 8000)"]
CMD ["hello-world.R"]
