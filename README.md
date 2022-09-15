[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/master/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a> <a href="https://benz0li.b-data.io/donate?project=1"><img src="https://benz0li.b-data.io/donate/static/donate-with-fosspay.png" alt="Donate with fosspay"></a>

# R docker stack

Multi-arch (`linux/amd64`, `linux/arm64/v8`) docker images:

*  [`registry.gitlab.b-data.ch/r/ver`](https://gitlab.b-data.ch/r/ver/container_registry)
    *  [`registry.gitlab.b-data.ch/r/r-ver`](https://gitlab.b-data.ch/r/r-ver/container_registry)
       (4.0.4 ≤ version < 4.2.0)
*  [`registry.gitlab.b-data.ch/r/base`](https://gitlab.b-data.ch/r/base/container_registry)
*  [`registry.gitlab.b-data.ch/r/tidyverse`](https://gitlab.b-data.ch/r/tidyverse/container_registry)
*  [`registry.gitlab.b-data.ch/r/verse`](https://gitlab.b-data.ch/r/verse/container_registry)
*  [`registry.gitlab.b-data.ch/r/geospatial`](https://gitlab.b-data.ch/r/geospatial/container_registry)

Images considered stable for R versions ≥ 4.2.0.  
:point_right: The current state may eventually be backported to versions ≥
4.0.4.

**Features**

`registry.gitlab.b-data.ch/r/ver` serves as base image for
`registry.gitlab.b-data.ch/jupyterlab/r/base`.

The other images are counterparts to the JupyterLab images but **without**

*  code-server
*  IRKernel
*  JupyterHub
*  JupyterLab
    *  JupyterLab Extensions
    *  JupyterLab Integrations
*  Jupyter Notebook
    *  Jupyter Notebook Conversion
*  LSP Servers
*  Oh My Zsh
    *  Powerlevel10k Theme
    *  MesloLGS NF Font

and any configuration thereof.

## Table of Contents

*  [Prerequisites](#prerequisites)
*  [Install](#install)
*  [Usage](#usage)
*  [Contributing](#contributing)
*  [License](#license)

## Prerequisites

This projects requires an installation of docker.

## Install

To install docker, follow the instructions for your platform:

*  [Install Docker Engine | Docker Documentation > Supported platforms](https://docs.docker.com/engine/install/#supported-platforms)
*  [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

## Usage

### Build image (ver)

latest:

```bash
cd ver && docker build \
  --build-arg R_VERSION=4.2.1 \
  -t r-ver \
  -f latest.Dockerfile .
```

version:

```bash
cd ver && docker build \
  -t r-ver:<major>.<minor>.<patch> \
  -f <major>.<minor>.<patch>.Dockerfile .
```

For `<major>.<minor>.<patch>` ≥ `4.2.0`.

### Run container

self built:

```bash
docker run -it --rm r-ver[:<major>.<minor>.<patch>]
```

from the project's GitLab Container Registries:

*  [`r/ver`](https://gitlab.b-data.ch/r/ver/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/r/ver[:<major>[.<minor>[.<patch>]]]
    ```
*  [`r/base`](https://gitlab.b-data.ch/r/base/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/r/base[:<major>[.<minor>[.<patch>]]]
    ```
*  [`r/tidyverse`](https://gitlab.b-data.ch/r/tidyverse/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/r/tidyverse[:<major>[.<minor>[.<patch>]]]
    ```
*  [`r/verse`](https://gitlab.b-data.ch/r/verse/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/r/verse[:<major>[.<minor>[.<patch>]]]
    ```
*  [`r/geospatial`](https://gitlab.b-data.ch/r/geospatial/container_registry)  
    ```bash
    docker run -it --rm \
      registry.gitlab.b-data.ch/r/geospatial[:<major>[.<minor>[.<patch>]]]
    ```

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) © 2020 b-data GmbH
