ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=13
ARG CUDA_IMAGE
ARG CUDA_IMAGE_SUBTAG
ARG BLAS=libopenblas-dev
ARG CUDA_VERSION
ARG R_VERSION
ARG PYTHON_VERSION
ARG CRAN=https://p3m.dev/cran/latest

FROM glcr.b-data.ch/r/rsi/${R_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} as rsi
FROM glcr.b-data.ch/python/psi${PYTHON_VERSION:+/}${PYTHON_VERSION:-:none}${PYTHON_VERSION:+/$BASE_IMAGE}${PYTHON_VERSION:+:$BASE_IMAGE_TAG} as psi

FROM ${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG}

ARG DEBIAN_FRONTEND=noninteractive

ARG BASE_IMAGE
ARG BASE_IMAGE_TAG
ARG CUDA_IMAGE
ARG CUDA_IMAGE_SUBTAG
ARG BLAS
ARG CUDA_VERSION
ARG R_VERSION
ARG PYTHON_VERSION
ARG CRAN
ARG BUILD_START

ARG CUDA_IMAGE_LICENSE=${CUDA_IMAGE:+"NVIDIA Deep Learning Container License"}
ARG IMAGE_LICENSE=${CUDA_IMAGE_LICENSE:-"MIT"}
ARG IMAGE_SOURCE=https://gitlab.b-data.ch/r/docker-stack
ARG IMAGE_VENDOR="b-data GmbH"
ARG IMAGE_AUTHORS="Olivier Benz <olivier.benz@b-data.ch>"

LABEL org.opencontainers.image.licenses="$IMAGE_LICENSE" \
      org.opencontainers.image.source="$IMAGE_SOURCE" \
      org.opencontainers.image.vendor="$IMAGE_VENDOR" \
      org.opencontainers.image.authors="$IMAGE_AUTHORS"

ENV BASE_IMAGE=${BASE_IMAGE}:${BASE_IMAGE_TAG} \
    CUDA_IMAGE=${CUDA_IMAGE}${CUDA_IMAGE:+:}${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG} \
    PARENT_IMAGE=${CUDA_IMAGE:-$BASE_IMAGE}:${CUDA_IMAGE:+$CUDA_VERSION}${CUDA_IMAGE:+-}${CUDA_IMAGE_SUBTAG:-$BASE_IMAGE_TAG} \
    R_VERSION=${R_VERSION} \
    PYTHON_VERSION=${PYTHON_VERSION} \
    CRAN=${CRAN} \
    BUILD_DATE=${BUILD_START}

ENV LANG=en_US.UTF-8 \
    TERM=xterm \
    TZ=Etc/UTC

## Install R
COPY --from=rsi /usr/local /usr/local
## Install Python
COPY --from=psi /usr/local /usr/local

RUN apt-get update \
  ## Copy script checkbashisms from package devscripts
  && apt-get download devscripts \
  && dpkg --force-depends --install devscripts*.deb \
  && cp -a /usr/bin/checkbashisms /usr/local/bin/checkbashisms \
  && dpkg --purge devscripts \
  && rm devscripts*.deb \
  ## Install R runtime dependencies
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    g++ \
    gfortran \
    libbz2-dev \
    '^libcurl[3|4]$' \
    libdeflate-dev \
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
    '^libtiff[5|6]$' \
    libzstd-dev \
    pkg-config \
    unzip \
    zip \
    zlib1g \
  ## Additional packages
  && apt-get install -y --no-install-recommends \
    bash-completion \
    file \
    fonts-texgyre \
    gsfonts \
    libxt6 \
    locales \
    netbase \
    tzdata \
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
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && mkdir -p ${RLS} \
  ## Set configured CRAN mirror
  && echo "options(repos = c(CRAN='$CRAN'), download.file.method = 'libcurl')" >> $(R RHOME)/etc/Rprofile.site \
  ## Use littler installation scripts
  && Rscript -e "install.packages(c('littler', 'docopt'), repos = '$CRAN')" \
  && ln -s ${RLS}/littler/examples/install2.r /usr/local/bin/install2.r \
  && ln -s ${RLS}/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
  && ln -s ${RLS}/littler/bin/r /usr/local/bin/r \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

CMD ["R"]
