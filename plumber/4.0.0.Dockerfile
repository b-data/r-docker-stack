FROM registry.gitlab.b-data.ch/r/r-ver:4.0.0

LABEL org.label-schema.vcs-url="https://gitlab.b-data.ch/r/yads"

WORKDIR /usr/src

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
  ## Install plumber
  && install2.r --error --deps TRUE plumber \
  ## Set up endpoint
  && echo '#* Return "hello world"\n#* @get /hello\nfunction() {\n  "hello world"\n}' > hello-world.R \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 8000

## Configure container startup
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(commandArgs()[6]); pr$run(host = '0.0.0.0', port = 8000)"]
CMD ["hello-world.R"]
