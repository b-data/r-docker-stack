ARG BUILD_ON_IMAGE=glcr.b-data.ch/r/tidyverse
ARG R_VERSION=4.2.2
ARG QUARTO_VERSION=1.2.335
ARG CTAN_REPO=https://www.texlive.info/tlnet-archive/2023/03/15/tlnet

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG QUARTO_VERSION
ARG CTAN_REPO
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    CTAN_REPO=${CTAN_REPO} \
    PATH=/opt/TinyTeX/bin/linux:/opt/quarto/bin:$PATH \
    BUILD_DATE=${BUILD_START}

## Add LaTeX, rticles and bookdown support
RUN dpkgArch="$(dpkg --print-architecture)" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    default-jdk \
    fonts-roboto \
    ghostscript \
    hugo \
    lbzip2 \
    libbz2-dev \
    libglpk-dev \
    libgmp3-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libharfbuzz-dev \
    libhunspell-dev \
    libicu-dev \
    liblzma-dev \
    libmagick++-dev \
    libopenmpi-dev \
    libpoppler-cpp-dev \
    librdf0-dev \
    qpdf \
    texinfo \
  ## Install R package redland
  && install2.r --error --skipinstalled -n $NCPUS redland \
  ## Explicitly install runtime library sub-deps of librdf0-dev
  && apt-get install -y \
    libcurl4-openssl-dev \
    libxslt-dev \
    librdf0 \
    redland-utils \
    rasqal-utils \
    raptor2-utils \
  ## Get rid of librdf0-dev and its dependencies (incl. libcurl4-gnutls-dev)
  && apt-get -y autoremove \
  && if [ ${dpkgArch} = "amd64" ]; then \
    ## Install quarto
    curl -sLO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz; \
    mkdir -p /opt/quarto; \
    tar -xzf quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz -C /opt/quarto --no-same-owner --strip-components=1; \
    rm quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz; \
    ## Remove quarto pandoc
    rm /opt/quarto/bin/tools/pandoc; \
    ## Link to system pandoc
    ln -s /usr/bin/pandoc /opt/quarto/bin/tools/pandoc; \
  fi \
  ## Tell APT about the TeX Live installation
  ## by building a dummy package using equivs
  && apt-get install -y --no-install-recommends equivs \
  && cd /tmp \
  && wget https://github.com/scottkosty/install-tl-ubuntu/raw/master/debian-control-texlive-in.txt \
  && equivs-build debian-* \
  && mv texlive-local*.deb texlive-local.deb \
  && dpkg -i texlive-local.deb \
  && apt-get -y purge equivs \
  && apt-get -y autoremove \
  ## Admin-based install of TinyTeX:
  && wget -qO- "https://yihui.org/tinytex/install-unx.sh" \
    | sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && ln -rs /opt/TinyTeX/bin/$(uname -m)-linux \
    /opt/TinyTeX/bin/linux \
  && /opt/TinyTeX/bin/linux/tlmgr path add \
  && tlmgr update --self \
  ## TeX packages as requested by the community
  && curl -sSLO https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt \
  && tlmgr install $(cat pkgs-yihui.txt | tr '\n' ' ') \
  && rm -f pkgs-yihui.txt \
  ## TeX packages as in rocker/verse
  && tlmgr install \
    context \
    pdfcrop \
  ## TeX packages as in jupyter/scipy-notebook
  && tlmgr install \
    cm-super \
    dvipng \
  ## TeX packages specific for nbconvert
  && tlmgr install \
    oberdiek \
    titling \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:${NB_GID} /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && install2.r --error --skipinstalled -n $NCPUS PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE --skipinstalled -n $NCPUS \
    blogdown \
    bookdown \
    distill \
    quarto \
    rticles \
    rmdshower \
    rJava \
    xaringan \
  ## Install Cairo: R Graphics Device using Cairo Graphics Library
  ## Install magick: Advanced Graphics and Image-Processing in R
  && install2.r --error --skipinstalled -n $NCPUS \
    Cairo \
    magick \
  ## Get rid of libharfbuzz-dev
  && apt-get -y purge libharfbuzz-dev \
  ## Get rid of libmagick++-dev
  && apt-get -y purge libmagick++-dev \
  ## and their dependencies (incl. python3)
  && apt-get -y autoremove \
  && apt-get -y install --no-install-recommends \
    '^libmagick\+\+-6.q16-[0-9]+$' \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
