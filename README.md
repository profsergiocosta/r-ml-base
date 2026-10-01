# r-ml-base

Base Docker image for R services using [Plumber](https://www.rplumber.io/), with "heavy" Machine Learning libraries pre-compiled and pre-installed.

## Why this image exists

Packages like `caret`, `randomForest` and `kernlab` have system-level dependencies (C/C++/Fortran compilation) that make `install.packages()` quite slow — every `docker build` of an application that uses them directly can take several minutes just on that step.

This image solves that by doing the heavy lifting once: it starts from `rstudio/plumber:latest`, installs the required system dependencies, and pre-installs the most expensive R packages. Services that need these packages can then use `r-ml-base` as their base image (`FROM`) and skip the compilation step, making the final application's build much faster.

> This image **does not** contain application code — it should only be used as a base for other `Dockerfile`s.

## What's included

**System dependencies** (via `apt-get`):
- `build-essential`
- `libcurl4-openssl-dev`
- `libssl-dev`
- `libgit2-dev`
- `libxml2-dev`
- `libcairo2-dev`
- `libxt-dev`
- `libfontconfig1-dev`
- `libpng-dev`

**R packages** (via `install_packages_base.R`):
- `kernlab`
- `caret`
- `fastshap`
- `dplyr`
- `ggfittext`
- `gggenes`
- `shapviz`
- `randomForest`

The CRAN repository used is configurable via the `CRAN_REPO` environment variable (default: `https://cloud.r-project.org`).

## Usage

### 1. Build the base image

```bash
docker build -f Dockerfile.base -t profsergiocosta/r-ml-base:latest .
```

Check that the packages are available (the Plumber image defines its own entrypoint, so override it):

```bash
docker run --rm --entrypoint Rscript profsergiocosta/r-ml-base:latest \
  -e 'for (p in c("caret", "randomForest", "kernlab")) cat(p, as.character(packageVersion(p)), "\n")'
```

Optionally, publish it to a registry (Docker Hub, GHCR, etc.) to reuse it across projects:

```bash
docker push profsergiocosta/r-ml-base:latest
```

### 2. Using it as a base for another service

In your R/Plumber service's `Dockerfile`:

```dockerfile
FROM profsergiocosta/r-ml-base:latest

WORKDIR /app
COPY . .

# Install only the packages specific to your application here
RUN Rscript -e "install.packages(c('your-specific-package'))"

EXPOSE 8000
ENTRYPOINT ["Rscript", "plumber.R"]
```

This way, the final service's build doesn't need to recompile `caret`, `randomForest` and the other heavy packages — they're already available in the base image.

## Reproducibility

By default the build is **not** frozen: the base is `rstudio/plumber:latest` and the R packages
are installed from the current state of CRAN, so two builds made on different dates can contain
different versions. For results that must be reproducible:

- pin the base image in `Dockerfile.base` to a specific tag or digest instead of `latest`;
- set `CRAN_REPO` (an `ENV` line in `Dockerfile.base`) to a dated CRAN snapshot, for example one
  from [Posit Public Package Manager](https://packagemanager.posit.co/) such as
  `https://packagemanager.posit.co/cran/2026-09-19`;
- tag the published image with a version (`profsergiocosta/r-ml-base:1.0.0`) and record that tag, or the image digest,
  in your own project instead of relying on `latest`.

## Adding new packages to the base

Edit `install_packages_base.R` and add the new package to the `packages` vector. Then rebuild and republish the base image so projects depending on it get access to the package.

```r
packages <- c(
  "kernlab",
  "caret",
  "fastshap",
  "dplyr",
  "ggfittext",
  "gggenes",
  "shapviz",
  "randomForest"
  # add other generic packages you always use here
)
```

## Repository structure

```
.
├── Dockerfile.base           # Base image definition
├── install_packages_base.R   # R package installation script
├── .github/workflows/        # CI: build, smoke test and publish to Docker Hub
├── CITATION.cff              # How to cite this image
├── LICENSE                   # MIT License
└── README.md
```

## Publishing (maintainers)

Pushing a version tag publishes the image through GitHub Actions (build, smoke tests, push, Docker Hub description sync). Pull requests that touch the Dockerfile or the package list only build and test.

```bash
git tag v1.0.0 && git push origin v1.0.0
```

Required repository secrets: `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` (access token with Read, Write, Delete scope). A tag `vX.Y.Z` (or `X.Y.Z`) publishes `X.Y.Z`, `X.Y` and `latest`. The first build compiles all the R packages and takes a while; later ones reuse the layer cache.

## Citation

If you use this image in your research, please cite it. GitHub's "Cite this repository" button
(from [`CITATION.cff`](CITATION.cff)) gives the reference in APA and BibTeX. Please also cite the
R packages you rely on (`citation("caret")`, for example).

## License

The files of this repository are released under the [MIT License](LICENSE). The image also
contains third-party software (R, Plumber, the R packages and system libraries) under their own
licenses, several of them GPL, which are not changed by this repository.

Maintained by Sérgio Souza Costa, [LambdaGeo](https://github.com/LambdaGeo) research group (UFMA).
