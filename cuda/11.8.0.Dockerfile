ARG BUILD_ON_IMAGE

ARG CUDA_HOME=/usr/local/cuda
ARG NVBLAS_CONFIG_FILE=/etc/nvblas.conf
ARG LIBNVINFER_MAJOR_VERSION=8

FROM ${BUILD_ON_IMAGE}

ARG CUDA_IMAGE_FLAVOR

ARG CUDA_HOME
ARG NVBLAS_CONFIG_FILE
ARG LIBNVINFER_MAJOR_VERSION
ARG CUPTI_AVAILABLE

ENV CUDA_HOME=${CUDA_HOME} \
    NVBLAS_CONFIG_FILE=${NVBLAS_CONFIG_FILE} \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}${LD_LIBRARY_PATH:+:}${CUDA_HOME}/lib:${CUDA_HOME}/lib64${CUPTI_AVAILABLE:+:${CUDA_HOME}/extras/CUPTI/lib64}

RUN cpuBlasLib="$(update-alternatives --query \
  libblas.so.3-$(uname -m)-linux-gnu | grep Value | cut -f2 -d' ')" \
  && dpkgArch="$(dpkg --print-architecture)" \
  ## NVBLAS log configuration
  && touch /var/log/nvblas.log \
  && chown :users /var/log/nvblas.log \
  && chmod g+rw /var/log/nvblas.log \
  ## Allow R to use NVBLAS, with fallback on OpenBLAS
  && echo "NVBLAS_LOGFILE /var/log/nvblas.log" > $NVBLAS_CONFIG_FILE \
  && echo "NVBLAS_CPU_BLAS_LIB $cpuBlasLib" >> $NVBLAS_CONFIG_FILE \
  && echo "NVBLAS_GPU_LIST ALL" >> $NVBLAS_CONFIG_FILE \
  ## Provide NVBLAS-enabled R and Rscript
  ## Enabled at runtime and only if nvidia-smi and at least one GPU are present
  && nvblasLib="$(cd $CUDA_HOME/lib* && ls libnvblas.so* | head -n 1)" \
  && cp -a $(which R) $(which R)_ \
  && echo '#!/bin/bash' > $(which R) \
  && echo "command -v nvidia-smi >/dev/null && nvidia-smi -L | grep 'GPU[[:space:]]\?[[:digit:]]\+' >/dev/null && export LD_PRELOAD=$nvblasLib" \
    >> $(which R) \
  && echo "$(which R)_ \"\${@}\"" >> $(which R) \
  && cp -a $(which Rscript) $(which Rscript)_ \
  && echo '#!/bin/bash' > $(which Rscript) \
  && echo "command -v nvidia-smi >/dev/null && nvidia-smi -L | grep 'GPU[[:space:]]\?[[:digit:]]\+' >/dev/null && export LD_PRELOAD=$nvblasLib" \
    >> $(which Rscript) \
  && echo "$(which Rscript)_ \"\${@}\"" >> $(which Rscript) \
  ## Install TensorRT
  ## libnvinfer is not yet available for Ubuntu 22.04 on sbsa (arm64)
  && if [ ${dpkgArch} = "amd64" -o ! ${BASE_IMAGE} = "ubuntu:22.04" ]; then \
    ## Install development libraries and headers
    ## if devel-flavor of CUDA image is used
    if [ ${CUDA_IMAGE_FLAVOR} = "devel" ]; then dev="-dev"; fi; \
    apt-get update; \
    apt-get -y install --no-install-recommends \
      libnvinfer${dev:-$LIBNVINFER_MAJOR_VERSION} \
      libnvinfer-plugin${dev:-$LIBNVINFER_MAJOR_VERSION}; \
  fi \
  ## Clean up
  && rm -rf /var/lib/apt/lists/*
