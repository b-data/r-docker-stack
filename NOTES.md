# Notes

## Tweaks

These images are tweaked as follows:

### Environment variables

* `DOWNLOAD_STATIC_LIBV8=1`: R (V8): Installing V8 on Linux, the alternative
  way. (base+ images)
* `RETICULATE_MINICONDA_ENABLED=0`: R (reticulate): Disable prompt to install
  miniconda. (base+ images)

**Versions**

* `R_VERSION`
* `PYTHON_VERSION`
* `GIT_VERSION`
* `GIT_LFS_VERSION`
* `PANDOC_VERSION`
* `QUARTO_VERSION` (verse+ images)

**Miscellaneous**

* `BASE_IMAGE`: Its very base, a [Docker Official Image](https://hub.docker.com/search?q=&type=image&image_filter=official).
* `PARENT_IMAGE`: The image it was built on.
* `BUILD_DATE`: The date it was built (ISO 8601 format).
* `CRAN`: The CRAN mirror URL.
* `CTAN_REPO`: The CTAN mirror URL. (verse+ images)

**`MRAN`**

Environment variable `MRAN` is deprecated:

> After January 31, 2023, we \[Microsoft\] will no longer maintain the CRAN Time
> Machine snapshots.

For *frozen* images (R versions ≥ 4.2.2), `CRAN` is no longer set to an `MRAN`
snapshot in `$(R RHOME)/etc/Rprofile.site`.

:point_right: Use [renv](https://rstudio.github.io/renv/) to create
**r**eproducible **env**ironments for your R projects as these will also work
without the images of this docker stack.

### TeX packages (verse+ images)

In addition to the TeX packages used in
[rocker/verse](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_texlive.sh),
[jupyter/scipy-notebook](https://github.com/jupyter/docker-stacks/blob/main/scipy-notebook/Dockerfile)
and required for `nbconvert`, the
[packages requested by the community](https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt)
are installed.

## Python

The Python version is selected as follows:

* The latest [Python version numba is compatible with](https://numba.readthedocs.io/en/stable/user/installing.html#compatibility).

This Python version is installed at `/user/local/bin`.

# Notes on CUDA

The CUDA and OS versions are selected as follows:

* CUDA: The lastest version that has image flavour `devel` including cuDNN
  available.
* OS: The latest version that has TensortRT libraries for both `amd64` and
  `arm64` available.

## Tweaks

* Provide NVBLAS-enabled R and Rscript.
  * Enabled at runtime and only if `nvidia-smi` and at least one GPU are
    present.
* Provide NVBLAS-enabled radian (base+ images).
  * Enabled at runtime and only if `nvidia-smi` and at least one GPU are
    present.

### Environment variables

**Versions**

* `CUDA_VERSION`

**Miscellaneous**

* `CUDA_IMAGE`: The CUDA image it is derived from.
