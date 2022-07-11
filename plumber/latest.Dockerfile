ARG R_VERSION

FROM registry.gitlab.b-data.ch/r/ver:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

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
  ## Install plumber
  && install2.r --error --deps TRUE  -n $NCPUS plumber \
  ## Set up endpoint
  && echo '#* Return "hello world"\n#* @get /hello\nfunction() {\n  "hello world"\n}' > hello-world.R \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 8000

## Configure container startup
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[6]); pr$run(host = '0.0.0.0', port = 8000)"]
CMD ["hello-world.R"]
