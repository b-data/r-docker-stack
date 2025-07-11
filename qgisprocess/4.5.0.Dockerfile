ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=12
ARG BUILD_ON_IMAGE=glcr.b-data.ch/r/geospatial
ARG R_VERSION=4.5.0
ARG QGIS_VERSION=3.42.3

ARG SAGA_VERSION
ARG OTB_VERSION
## OTB_VERSION=9.1.1

ARG PROC_SAGA_NG_VERSION

FROM glcr.b-data.ch/qgis/qgissi/${QGIS_VERSION}/${BASE_IMAGE}:${BASE_IMAGE_TAG} as qgissi
FROM glcr.b-data.ch/saga-gis/saga-gissi${SAGA_VERSION:+/}${SAGA_VERSION:-:none}${SAGA_VERSION:+/$BASE_IMAGE}${SAGA_VERSION:+:$BASE_IMAGE_TAG} as saga-gissi
FROM glcr.b-data.ch/orfeotoolbox/otbsi${OTB_VERSION:+/}${OTB_VERSION:-:none}${OTB_VERSION:+/$BASE_IMAGE}${OTB_VERSION:+:$BASE_IMAGE_TAG} as otbsi

FROM ${BUILD_ON_IMAGE}:${R_VERSION}

ARG NCPUS=1

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG QGIS_VERSION
ARG SAGA_VERSION
ARG OTB_VERSION
ARG PROC_SAGA_NG_VERSION
ARG BUILD_START

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${R_VERSION} \
    QGIS_VERSION=${QGIS_VERSION} \
    SAGA_VERSION=${SAGA_VERSION} \
    OTB_VERSION=${OTB_VERSION} \
    BUILD_DATE=${BUILD_START}

    ## GRASS GIS: Make sure the distro's python is used
ENV GRASS_PYTHON=/usr/bin/python3

## Install QGIS
COPY --from=qgissi /usr /usr
## Install SAGA GIS
COPY --from=saga-gissi /usr /usr
## Install Orfeo Toolbox
COPY --from=otbsi /usr/local /usr/local
ENV GDAL_DRIVER_PATH=${OTB_VERSION:+disable} \
    OTB_APPLICATION_PATH=${OTB_VERSION:+/usr/local/lib/otb/applications} \
    OTB_INSTALL_DIR=${OTB_VERSION:+/usr/local}
ENV OTB_APPLICATION_PATH=${OTB_APPLICATION_PATH:-/usr/lib/otb/applications} \
    OTB_INSTALL_DIR=${OTB_INSTALL_DIR:-/usr}

RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    ## Multimedia files trancoding
    ffmpeg \
    ## QGIS: Additional runtime dependencies
    '^libexiv2-[0-9]+$' \
    '^libgdal[0-9]+$' \
    libgeos-c1v5 \
    '^libgsl[0-9]+$' \
    libjs-jquery \
    libjs-leaflet \
    '^libprotobuf-lite[0-9]+$' \
    libqca-qt5-2-plugins \
    '^libqscintilla2-qt5-[0-9]+$' \
    libqt5core5a \
    libqt5gui5 \
    libqt5keychain1 \
    libqt5multimediawidgets5 \
    libqt5network5 \
    libqt5quickwidgets5 \
    libqt5serialport5 \
    libqt5sql5 \
    libqt5webkit5 \
    libqt5widgets5 \
    libqt5xml5 \
    libqwt-qt5-6 \
    '^libspatialindex[0-9]+$' \
    '^libzip[0-9]+$' \
    ocl-icd-libopencl1 \
    qt3d-assimpsceneimport-plugin \
    qt3d-defaultgeometryloader-plugin \
    qt3d-gltfsceneio-plugin \
    qt3d-scene2d-plugin \
    qt5-image-formats-plugins \
    ## QGIS: Python 3 Support
    gdal-bin \
    libfcgi0ldbl \
    libsqlite3-mod-spatialite \
    python3-gdal \
    python3-jinja2 \
    python3-lxml \
    python3-matplotlib \
    python3-owslib \
    python3-plotly \
    python3-psycopg2 \
    python3-pygments \
    python3-pyproj \
    python3-pyqt5 \
    python3-pyqt5.qsci \
    python3-pyqt5.qtmultimedia \
    python3-pyqt5.qtpositioning \
    python3-pyqt5.qtserialport \
    python3-pyqt5.qtsql \
    python3-pyqt5.qtsvg \
    python3-pyqt5.qtwebkit \
    python3-sip \
    python3-yaml \
    qttools5-dev-tools \
    ## QGIS: Additional runtime recommendations
    grass \
    ## QGIS: Additional runtime suggestions
    gpsbabel \
    ## SAGA GIS: Supplementary runtime dependencies [^1]
    libdxflib3 \
    libhpdf-2.3.0 \
    libsvm3 \
    libwxgtk3.*-dev \
    $(test -z "${SAGA_VERSION}" && echo "saga") \
  ## Orfeo Toolbox: Supplementary runtime dependencies
  && if [ "$(uname -m)" = "x86_64" ]; then \
    apt-get -y install --no-install-recommends \
      '^libboost-filesystem[0-9].[0-9]+.[0-9]$' \
      '^libboost-serialization[0-9].[0-9]+.[0-9]$' \
      libglew2.* \
      '^libinsighttoolkit4.[0-9]+$' \
      libmuparser2v5 \
      libmuparserx4.* \
      '^libopencv-core[0-9][0-9.][0-9][a-z]?$' \
      '^libopencv-ml[0-9][0-9.][0-9][a-z]?$' \
      libtinyxml-dev \
      $(test -z "${OTB_VERSION}" && echo "otb-* monteverdi"); \
    if [ ! -z "${OTB_VERSION}" ]; then \
      if [ "$(echo ${OTB_VERSION} | cut -c 1)" -lt "8" ]; then \
        apt-get -y install --no-install-recommends \
          '^libopenthreads[0-9]+$' \
          libossim1; \
      fi; \
      ## Orfeo Toolbox: Clean up installation
      bash -c 'rm -rf /usr/local/{otbenv.profile,recompile_bindings.sh,tools}'; \
      if [ -f /usr/local/README ]; then \
        mv /usr/local/README /usr/local/share/doc/otb; \
      fi; \
      if [ -f /usr/local/LICENSE ]; then \
        mv /usr/local/LICENSE /usr/local/share/doc/otb; \
      fi \
    else \
      mkdir -p /usr/lib/otb; \
      ln -rs /usr/lib/$(uname -m)-linux-gnu/otb/applications \
        /usr/lib/otb/applications; \
    fi \
  fi \
  ## GRASS GIS: Configure dynamic linker run time bindings
  && echo "$(grass --config path)/lib" | tee /etc/ld.so.conf.d/libgrass.conf \
  && ldconfig \
  ## SAGA GIS: Add en_GB.UTF-8 and update locale
  && sed -i "s/# $LANG/$LANG/g" /etc/locale.gen \
  && sed -i "s/# en_GB.UTF-8/en_GB.UTF-8/g" /etc/locale.gen \
  && locale-gen \
  ## [^1]: SAGA GIS: libvigraimpex11 is not available for jammy
  && if $(! grep -q "jammy" /etc/os-release); then \
    apt-get -y install --no-install-recommends '^libvigraimpex[0-9]+$'; \
  fi \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.grass*

## Install QGIS related stuff
RUN apt-get update \
  ## Install QGIS-Plugin-Manager
  && apt-get -y install --no-install-recommends python3-pip \
  && export PIP_BREAK_SYSTEM_PACKAGES=1 \
  && /usr/bin/pip install qgis-plugin-manager \
  ## Install qgisprocess, the R interface to QGIS
  && install2.r --error --skipinstalled -n $NCPUS qgisprocess \
  ## Strip libraries of binary packages installed from PPPM
  && RLS=$(Rscript -e "cat(Sys.getenv('R_LIBS_SITE'))") \
  && strip ${RLS}/*/libs/*.so \
  ## Clean up
  && if [ ! -z "$PYTHON_VERSION" ]; then \
    apt-get -y purge python3-pip; \
    apt-get -y autoremove; \
  fi \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/* \
    ${HOME}/.cache \
    ${HOME}/.config \
    ${HOME}/.local

    ## Qt: Support running on headless computer
ENV QT_QPA_PLATFORM=offscreen

  ## QGIS: Install plugin 'Processing Saga NextGen Provider'
RUN mkdir -p ${HOME}/.local/share/QGIS/QGIS3/profiles/default/python/plugins \
  && cd ${HOME}/.local/share/QGIS/QGIS3/profiles/default/python/plugins \
  && qgis-plugin-manager init \
  && qgis-plugin-manager update \
  && qgis-plugin-manager install 'Processing Saga NextGen Provider'=="${PROC_SAGA_NG_VERSION:-0.0.7}" \
  ## QGIS: Enable plugins
  && qgis_process plugins enable processing_saga_nextgen \
  && qgis_process plugins enable grassprovider \
  ## QGIS: Add custom environment variable
  && mkdir -p ${HOME}/.local/share/QGIS/QGIS3/profiles/default/QGIS \
  && qgis3Ini="${HOME}/.local/share/QGIS/QGIS3/profiles/default/QGIS/QGIS3.ini" \
  && echo "\n[qgis]" >> ${qgis3Ini} \
  && echo 'customEnvVars="append|PYTHONPATH=:/usr/lib/python3/dist-packages"' >> \
    ${qgis3Ini} \
  && echo "customEnvVarsUse=true\n" >> ${qgis3Ini} \
  && if [ "$(uname -m)" = "x86_64" ]; then \
    ## QGIS: Set OTB application folder and OTB folder
    echo "\n[Processing]" >> ${qgis3Ini}; \
    if [ -z "${OTB_VERSION}" ]; then \
      echo "Configuration\OTB_APP_FOLDER=/usr/lib/otb/applications" >> \
        ${qgis3Ini}; \
      echo "Configuration\OTB_FOLDER=/usr\n" >> ${qgis3Ini}; \
    else \
      echo "Configuration\OTB_APP_FOLDER=/usr/local/lib/otb/applications" >> \
        ${qgis3Ini}; \
      echo "Configuration\OTB_FOLDER=/usr/local\n" >> ${qgis3Ini}; \
    fi; \
    ## QGIS: Install and enable OTB plugin
    qgis-plugin-manager install 'OrfeoToolbox Provider'; \
    qgis_process plugins enable orfeoToolbox_provider; \
  fi \
  && rm -rf .cache_qgis_plugin_manager \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf \
    ${HOME}/.cache/QGIS \
    ${HOME}/.cache/qgis_process* \
    ${HOME}/.config \
    ${HOME}/.grass*

ENV PYTHONPATH=${PYTHONPATH:+$PYTHONPATH:}${OTB_VERSION:+/usr/local/lib/otb/python}
