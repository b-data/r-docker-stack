[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a>

| See the [CUDA-based R docker stack](CUDA.md) for GPU accelerated docker images. |
|---------------------------------------------------------------------------------|

# R docker stack

Multi-arch (`linux/amd64`, `linux/arm64/v8`) docker images:

* [`glcr.b-data.ch/r/ver`](https://gitlab.b-data.ch/r/ver/container_registry)
  * [`glcr.b-data.ch/r/r-ver`](https://gitlab.b-data.ch/r/r-ver/container_registry)
    (4.0.4 ≤ version < 4.2.0)
* [`glcr.b-data.ch/r/base`](https://gitlab.b-data.ch/r/base/container_registry)
* [`glcr.b-data.ch/r/tidyverse`](https://gitlab.b-data.ch/r/tidyverse/container_registry)
* [`glcr.b-data.ch/r/verse`](https://gitlab.b-data.ch/r/verse/container_registry)
* [`glcr.b-data.ch/r/geospatial`](https://gitlab.b-data.ch/r/geospatial/container_registry)
* [`glcr.b-data.ch/r/qgisprocess`](https://gitlab.b-data.ch/r/qgisprocess/container_registry)
  (versions ≥ 4.3.0)

Images considered stable for R versions ≥ 4.2.0.  
:point_right: The current state may eventually be backported to versions ≥
4.0.4.

**Build chain**

ver → base → tidyverse → verse → geospatial → qgisprocess  
:information_source: The term base+ means *base or later* in the build chain.

**Features**

`glcr.b-data.ch/r/ver` serves as parent image for
`glcr.b-data.ch/jupyterlab/r/base`.

The other images are counterparts to the JupyterLab images but **without**

* code-server
* IRKernel
* JupyterHub
* JupyterLab
  * JupyterLab Extensions
  * JupyterLab Integrations
* Jupyter Notebook
  * Jupyter Notebook Conversion
* LSP Servers
* Oh My Zsh
  * Powerlevel10k Theme
  * MesloLGS NF Font

and any configuration thereof.

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Contributing](#contributing)
* [Support](#support)
* [License](#license)

## Prerequisites

This projects requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

* [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
* [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image (ver)

*latest*:

```bash
docker build \
  --build-arg R_VERSION=4.5.1 \
  --build-arg PYTHON_VERSION=3.12.11 \
  -t r/ver \
  -f ver/latest.Dockerfile .
```

*version*:

```bash
docker build \
  -t r/ver:MAJOR.MINOR.PATCH \
  -f ver/MAJOR.MINOR.PATCH.Dockerfile .
```

For `MAJOR.MINOR.PATCH` ≥ `4.2.0`.

### Run container

self built:

```bash
docker run -it --rm r/ver[:MAJOR.MINOR.PATCH]
```

from the project's GitLab Container Registries:

```bash
docker run -it --rm \
  IMAGE[:MAJOR[.MINOR[.PATCH]]]
```

`IMAGE` being one of

* [`glcr.b-data.ch/r/ver`](https://gitlab.b-data.ch/r/ver/container_registry)
* [`glcr.b-data.ch/r/base`](https://gitlab.b-data.ch/r/base/container_registry)
* [`glcr.b-data.ch/r/tidyverse`](https://gitlab.b-data.ch/r/tidyverse/container_registry)
* [`glcr.b-data.ch/r/verse`](https://gitlab.b-data.ch/r/verse/container_registry)
* [`glcr.b-data.ch/r/geospatial`](https://gitlab.b-data.ch/r/geospatial/container_registry)
* [`glcr.b-data.ch/r/qgisprocess`](https://gitlab.b-data.ch/r/qgisprocess/container_registry)

See [Notes](NOTES.md) for tweaks.

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## Support

Community support: Open a new discussion
[here](https://github.com/orgs/b-data/discussions).

Commercial support: Contact b-data by [email](mailto:support@b-data.ch).

## License

Copyright © 2020 b-data GmbH

Distributed under the terms of the [MIT License](LICENSE).
