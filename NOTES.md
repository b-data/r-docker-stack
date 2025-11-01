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
* `PARENT_IMAGE`: The image it was derived from.
* `BUILD_DATE`: The date it was built (ISO 8601 format).
* `CRAN`: The CRAN mirror URL.
* `CTAN_REPO`: The CTAN mirror URL. (verse+ images)

**`MRAN`**

Environment variable `MRAN` is deprecated:

> After January 31, 2023, we \[Microsoft\] will no longer maintain the CRAN Time
> Machine snapshots.

Current situation regarding *frozen* images:

* R version < 4.2.2: MRAN retired; CRAN snapshots broken.
* 4.2.2 ≤ R version < 4.3.1: No CRAN snapshots available.
    * Use [renv](https://rstudio.github.io/renv/) to create **r**eproducible
      **env**ironments for your R projects.
* R version ≥ 4.3.1: CRAN snapshots reinstated (PPM).

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

This Python version is installed at `/usr/local/bin`.

# Additional notes on CUDA

The CUDA version is selected as follows:

* CUDA: The lastest version that has image flavour `devel` including cuDNN
  available.

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

## Basic Linear Algebra Subprograms (BLAS)

These images use OpenBLAS by default.

To have `R` and `Rscript` use NVBLAS instead, copy the NVBLAS-enabled
executables to `~/.local/bin`:

```bash
mkdir -p $HOME/.local/bin;
for file in $(which {R,Rscript}); do
  cp "$file"_ "$HOME/.local/bin/$(basename $file)";
done
```

and restart the terminal.

:information_source: The
[xgboost](https://cran.r-project.org/package=xgboost) package benefits greatly
from NVBLAS, if it is
[installed correctly](https://xgboost.readthedocs.io/en/stable/build.html).
