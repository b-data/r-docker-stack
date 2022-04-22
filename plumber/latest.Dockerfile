FROM registry.gitlab.b-data.ch/r/r-ver:4.2.0

LABEL org.opencontainers.image.source="https://gitlab.b-data.ch/r/yads"

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    libcurl4-openssl-dev \
    libsodium-dev \
    libssl-dev \
    libxml2-dev \
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
