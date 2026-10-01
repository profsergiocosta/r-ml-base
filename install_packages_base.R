options(repos = c(CRAN = Sys.getenv("CRAN_REPO", unset = "https://cloud.r-project.org")))

# Pacotes "pesados" que demoram para compilar
packages <- c(
  "kernlab",
  "caret",
  "fastshap",
  "dplyr",
  "ggfittext",
  "gggenes",
  "shapviz",
  "randomForest"
  # Adicione aqui outros pacotes genéricos que você sempre usa
)

is_installed <- function(pkgs) {
  vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)
}

missing <- packages[!is_installed(packages)]
if (length(missing) > 0) {
  message(">> Instalando: ", paste(missing, collapse = ", "))
  # Dependências no padrão do R (Depends, Imports e LinkingTo): sem elas, pacotes como o
  # caret não carregam. Ncpus compila vários pacotes em paralelo.
  install.packages(missing, Ncpus = max(1L, parallel::detectCores()))
}

failed <- packages[!is_installed(packages)]
if (length(failed) > 0) {
  stop("❌ Falha ao instalar: ", paste(failed, collapse = ", "))
}
message("✅ Base image packages ready!")
