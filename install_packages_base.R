# Define repositório CRAN (com fallback seguro)
cran_repo <- Sys.getenv("CRAN_REPO", unset = "https://cloud.r-project.org")
options(repos = c(CRAN = cran_repo))

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
  message(">> Pacotes pendentes: ", paste(missing, collapse = ", "))
  ncpus <- max(1L, parallel::detectCores())
  
  # 1. Tratar o fastshap separadamente (removido do CRAN, agora no r-universe)
  if ("fastshap" %in% missing) {
    message(">> Instalando fastshap via r-universe...")
    install.packages(
      "fastshap", 
      repos = c("https://bgreenwell.r-universe.dev", cran_repo),
      Ncpus = ncpus
    )
    # Remove da lista de pendentes para evitar tentativa redundante
    missing <- setdiff(missing, "fastshap")
  }
  
  # 2. Instalar os demais pacotes via CRAN padrão
  if (length(missing) > 0) {
    message(">> Instalando via CRAN: ", paste(missing, collapse = ", "))
    install.packages(missing, Ncpus = ncpus)
  }
}

# Verificação final de falhas
failed <- packages[!is_installed(packages)]
if (length(failed) > 0) {
  stop("❌ Falha ao instalar: ", paste(failed, collapse = ", "))
}

message("✅ Base image packages ready!")