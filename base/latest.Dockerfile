ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=12
ARG BUILD_ON_IMAGE=glcr.b-data.ch/r/ver
ARG R_VERSION
ARG NEOVIM_VERSION=0.11.3
ARG GIT_VERSION=2.50.1
ARG GIT_LFS_VERSION=3.7.0
ARG PANDOC_VERSION=3.6.3

FROM glcr.b-data.ch/neovim/nvsi:${NEOVIM_VERSION} AS nvsi
FROM glcr.b-data.ch/git/gsi/${GIT_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} as gsi
FROM glcr.b-data.ch/git-lfs/glfsi:${GIT_LFS_VERSION} as glfsi

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG NEOVIM_VERSION
ARG GIT_VERSION
ARG GIT_LFS_VERSION
ARG PANDOC_VERSION
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    NEOVIM_VERSION=${NEOVIM_VERSION} \
    GIT_VERSION=${GIT_VERSION} \
    GIT_LFS_VERSION=${GIT_LFS_VERSION} \
    PANDOC_VERSION=${PANDOC_VERSION} \
    BUILD_DATE=${BUILD_START}

## Installing V8 on Linux, the alternative way
## https://ropensci.org/blog/2020/11/12/installing-v8
ENV DOWNLOAD_STATIC_LIBV8=1

## Disable prompt to install miniconda
ENV RETICULATE_MINICONDA_ENABLED=0

## Install Neovim
COPY --from=nvsi /usr/local /usr/local
## Install Git
COPY --from=gsi /usr/local /usr/local
## Install Git LFS
COPY --from=glfsi /usr/local /usr/local

RUN dpkgArch="$(dpkg --print-architecture)" \
  && apt-get update \
  && apt-get -y install --no-install-recommends \
    bash-completion \
    build-essential \
    curl \
    file \
    fontconfig \
    g++ \
    gcc \
    gfortran \
    gnupg \
    htop \
    info \
    jq \
    libclang-dev \
    man-db \
    nano \
    ncdu \
    procps \
    psmisc \
    screen \
    sudo \
    swig \
    tmux \
    vim-tiny \
    wget \
    zsh \
    ## Neovim: Additional runtime recommendations
    ripgrep \
    ## Git: Additional runtime dependencies
    libcurl3-gnutls \
    liberror-perl \
    ## Git: Additional runtime recommendations
    less \
    ssh-client \
  ## Python: Additional dev dependencies
  && if [ -z "$PYTHON_VERSION" ]; then \
    apt-get -y install --no-install-recommends \
      python3-dev \
      ## Install Python package installer
      ## (dep: python3-distutils, python3-setuptools and python3-wheel)
      python3-pip \
      ## Install venv module for python3
      python3-venv; \
    ## make some useful symlinks that are expected to exist
    ## ("/usr/bin/python" and friends)
    for src in pydoc3 python3 python3-config; do \
      dst="$(echo "$src" | tr -d 3)"; \
      if [ -s "/usr/bin/$src" ] && [ ! -e "/usr/bin/$dst" ]; then \
        ln -svT "$src" "/usr/bin/$dst"; \
      fi \
    done; \
  else \
    ## Force update pip, setuptools and wheel
    pip install --upgrade --force-reinstall \
      pip \
      setuptools \
      wheel; \
  fi \
  ## Git: Set default branch name to main
  && git config --system init.defaultBranch main \
  ## Git: Store passwords for one hour in memory
  && git config --system credential.helper "cache --timeout=3600" \
  ## Git: Merge the default branch from the default remote when "git pull" is run
  && git config --system pull.rebase false \
  ## Install pandoc
  && curl -sLO https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && dpkg -i pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  && rm pandoc-${PANDOC_VERSION}-1-${dpkgArch}.deb \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache

## Install R related stuff
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    ## Current ZeroMQ library for R pbdZMQ
    libzmq3-dev \
    ## Required for R extension
    libcairo2-dev \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libssl-dev \
    libtiff-dev \
    libxml2-dev \
  ## Install radian
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && pip install radian \
  ## Provide NVBLAS-enabled radian_
  ## Enabled at runtime and only if nvidia-smi and at least one GPU are present
  && if [ ! -z "$CUDA_IMAGE" ]; then \
    nvblasLib="$(cd $CUDA_HOME/lib* && ls libnvblas.so* | head -n 1)"; \
    cp -a $(which radian) $(which radian)_; \
    echo '#!/bin/bash' > $(which radian)_; \
    echo "command -v nvidia-smi >/dev/null && nvidia-smi -L | grep 'GPU[[:space:]]\?[[:digit:]]\+' >/dev/null && export LD_PRELOAD=$nvblasLib" \
      >> $(which radian)_; \
    echo "$(which radian) \"\${@}\"" >> $(which radian)_; \
  fi \
  ## Install httpgd
  ## Archived on 2025-04-23 as issues were not corrected in time.
  && install2.r --error --skipinstalled -n $NCPUS \
    unigd \
    AsioHeaders \
  && curl -sLO https://cran.r-project.org/src/contrib/Archive/httpgd/httpgd_2.0.4.tar.gz \
  && R CMD INSTALL httpgd_2.0.4.tar.gz \
  && rm httpgd_2.0.4.tar.gz \
  ## Get rid of libcairo2-dev and its dependencies (incl. python3)
  && apt-get -y purge libcairo2-dev \
  && apt-get -y autoremove \
  ## Strip libraries of binary packages installed from P3M
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && strip ${RLS}/*/libs/*.so \
  ## Clean up
  && rm -rf /tmp/* \
    /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.config \
    ${HOME}/.ipython \
    ${HOME}/.local
