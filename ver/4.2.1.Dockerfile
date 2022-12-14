ARG BASE_IMAGE=debian:bullseye
ARG BLAS=libopenblas-dev
ARG R_VERSION=4.2.1
ARG CRAN=https://cloud.r-project.org

FROM registry.gitlab.b-data.ch/r/rsi/${R_VERSION}/${BASE_IMAGE} as rsi

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://gitlab.b-data.ch/r/docker-stack" \
      org.opencontainers.image.vendor="b-data GmbH" \
      org.opencontainers.image.authors="Olivier Benz <olivier.benz@b-data.ch>"

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BLAS
ARG R_VERSION
ARG CRAN
ARG BUILD_DATE

ENV BASE_IMAGE=${BASE_IMAGE} \
    R_VERSION=${R_VERSION} \
    CRAN=${CRAN} \
    BUILD_DATE=${BUILD_DATE:-2022-10-31} \
    LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

COPY --from=rsi /usr/local /usr/local

RUN apt-get update \
  ## Copy script checkbashisms from package devscripts
  && apt-get install -y --no-install-recommends devscripts \
  && cp -a /usr/bin/checkbashisms /usr/local/bin/checkbashisms \
  && apt-get remove -y --purge devscripts \
  && apt-get autoremove -y \
  ## Install R runtime dependencies
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    fonts-texgyre \
    g++ \
    gfortran \
    libbz2-dev \
    '^libcurl[3|4]$' \
    libicu-dev \
    '^libjpeg.*-turbo.*-dev$' \
    liblapack-dev \
    liblzma-dev \
    ${BLAS} \
    libpangocairo-1.0-0 \
    libpaper-utils \
    '^libpcre[2|3]-dev$' \
    libpng-dev \
    libreadline-dev \
    libtiff5 \
    pkg-config \
    unzip \
    zip \
    zlib1g \
  ## Additional packages
  && apt-get install -y --no-install-recommends \
    bash-completion \
    file \
    gsfonts \
    locales \
  ## Switch BLAS/LAPACK (manual mode)
  && if [ ${BLAS} = "libopenblas-dev" ]; then \
    update-alternatives --set libblas.so.3-$(uname -m)-linux-gnu \
      /usr/lib/$(uname -m)-linux-gnu/openblas-pthread/libblas.so.3; \
    update-alternatives --set liblapack.so.3-$(uname -m)-linux-gnu \
      /usr/lib/$(uname -m)-linux-gnu/openblas-pthread/liblapack.so.3; \
  fi \
  ## Update locale
  && sed -i "s/# $LANG/$LANG/g" /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=$LANG \
  ## Add directory for site-library
  && mkdir -p $(R RHOME)/site-library \
  ## Set configured CRAN mirror
  && if [ -z "$BUILD_DATE" ]; then MRAN=$CRAN; \
   else MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE}; fi \
  && echo MRAN=$MRAN >> /etc/environment \
  && echo "options(repos = c(CRAN='$MRAN'), download.file.method = 'libcurl')" >> $(R RHOME)/etc/Rprofile.site \
  ## Use littler installation scripts
  && Rscript -e "install.packages(c('littler', 'docopt'), repos = '$MRAN')" \
  && ln -s $(R RHOME)/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s $(R RHOME)/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s $(R RHOME)/site-library/littler/bin/r /usr/local/bin/r \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

CMD ["R"]
