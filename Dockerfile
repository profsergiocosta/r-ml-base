# Imagem base com R + Plumber + pacotes pesados pré-instalados
FROM rstudio/plumber:latest

# Define repositório CRAN (sem espaços!)
ENV CRAN_REPO="https://cloud.r-project.org"

WORKDIR /app

# Dependências do sistema para compilar pacotes R
RUN apt-get update && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libgit2-dev \
    libxml2-dev \
    libcairo2-dev \
    libxt-dev \
    libfontconfig1-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Script de instalação dos pacotes "pesados"
COPY install_packages_base.R .
RUN Rscript -e "options(repos = c(CRAN = Sys.getenv('CRAN_REPO'))); source('install_packages_base.R')"

# Deixa a imagem pronta para receber código depois
# Não copie o código da aplicação aqui!