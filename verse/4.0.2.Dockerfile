FROM registry.gitlab.b-data.ch/r/tidyverse:4.0.2

# Version-stable CTAN repo from the tlnet archive at texlive.info, used in the
# TinyTeX installation: chosen as the frozen snapshot of the TeXLive release
# shipped for the base Debian image of a given rocker/r-ver tag.
# Debian buster => TeXLive 2018, frozen release snapshot 2019/02/27
ARG CTAN_REPO=${CTAN_REPO:-https://www.texlive.info/tlnet-archive/2019/02/27/tlnet}
ENV CTAN_REPO=${CTAN_REPO}

ENV PATH=$PATH:/opt/TinyTeX/bin/x86_64-linux/

## Add LaTeX, rticles and bookdown support
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    ## for rJava
    default-jdk \
    ## Nice Google fonts
    fonts-roboto \
    ## used by some base R plots
    ghostscript \
    ## used to build rJava and other packages
    libbz2-dev \
    libicu-dev \
    liblzma-dev \
    libpcre2-dev \
    ## system dependency of hunspell (devtools)
    libhunspell-dev \
    ## system dependency of hadley/pkgdown
    libmagick++-dev \
    ## system dependency of pdftools
    libpoppler-cpp-dev \
    ## rdf, for redland / linked data
    librdf0-dev \
    ## for V8-based javascript wrappers
    libv8-dev \
    ## R CMD Check wants qpdf to check pdf sizes, or throws a Warning
    qpdf \
    ## For building PDF manuals
    texinfo \
    ## parallelization
    libzmq3-dev \
    libopenmpi-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  ## Use tinytex for LaTeX installation
  #&& install2.r --error tinytex \
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
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && if /opt/TinyTeX/bin/*/tex -v | grep -q 'TeX Live 2018'; then \
      ## Patch the Perl modules in the frozen TeX Live 2018 snapshot with the newer
      ## version available for the installer in tlnet/tlpkg/TeXLive, to include the
      ## fix described in https://github.com/yihui/tinytex/issues/77#issuecomment-466584510
      ## as discussed in https://www.preining.info/blog/2019/09/tex-services-at-texlive-info/#comments
      wget -P /tmp/ ${CTAN_REPO}/install-tl-unx.tar.gz \
      && tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp/ \
      && cp -Tr /tmp/install-tl-*/tlpkg/TeXLive /opt/TinyTeX/tlpkg/TeXLive \
      && rm -r /tmp/install-tl-*; \
    fi \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install ae inconsolata listings metafont mfware parskip pdfcrop tex xcolor \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:users /opt/TinyTeX \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  && install2.r --error PKI \
  ## And some nice R packages for publishing-related stuff
  && install2.r --error --deps TRUE \
    bookdown rticles rmdshower rJava \
  ## Clean up
  && rm -rf /tmp/*
#
## Consider including:
# - yihui/printr R package (when released to CRAN)
# - libgsl0-dev (GSL math library dependencies)
