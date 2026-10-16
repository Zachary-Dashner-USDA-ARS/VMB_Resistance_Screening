# Reproducible environment for:
#   Dashner ZS, Uchima SY, Sisterson MS and Riaz S.
#   Laboratory cohort assays as a tool to evaluate grapevine germplasm for
#   resistance to vine mealybug (Planococcus ficus). Am J Enol Vitic.
#
# Pins R 4.6.0 and every package version recorded in renv.lock.
# Anyone with Docker gets a bit-for-bit identical package set, on any OS.
#
# BUILD
#   docker build -t vmb-resistance .
#
# RUN (RStudio in a browser at http://localhost:8787, user rstudio / pw vmb)
#   docker run --rm -p 8787:8787 -e PASSWORD=vmb \
#     -v "$(pwd)":/home/rstudio/project vmb-resistance
#
# RUN (headless — render the notebook and exit)
#   docker run --rm -v "$(pwd)":/home/rstudio/project vmb-resistance \
#     Rscript -e 'rmarkdown::render("/home/rstudio/project/analysis/01_VMB_resistance_analysis.Rmd")'
#
# Apple Silicon: arm64 builds of rocker images work, but if a package fails to
# compile natively, force the Intel build (slower, via emulation):
#   docker build --platform linux/amd64 -t vmb-resistance .

FROM rocker/rstudio:4.6.0

LABEL org.opencontainers.image.title="VMB resistance screening"
LABEL org.opencontainers.image.description="Analysis environment for Dashner et al., AJEV"
LABEL org.opencontainers.image.licenses="US Public Domain (USDA-ARS)"

# System libraries needed to compile the spatial/stats stack from source.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libfontconfig1-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libfreetype6-dev \
        libpng-dev \
        libtiff5-dev \
        libjpeg-dev \
        libglpk-dev \
        libgit2-dev \
        cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/rstudio/project

# Restore the package library first, in its own layer, so edits to the
# analysis don't trigger a full reinstall on rebuild.
COPY renv.lock renv.lock
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')" \
 && R -e "renv::restore(lockfile = 'renv.lock', prompt = FALSE)"

COPY . .

RUN chown -R rstudio:rstudio /home/rstudio/project
