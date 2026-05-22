coletar_ipca_mensal <- function() {
  dados <- rbcb::get_series(433, as = "tibble")
  colnames(dados) <- c("date", "ipca_mm")
  dados
}

coletar_meta_inflacao <- function() {
  dados <- rbcb::get_series(13521, as = "tibble")
  colnames(dados) <- c("date", "meta_inflacao")
  dados
}

coletar_ipca_grupos <- function() {
  sidrar::get_sidra(
    api = "/t/7060/n1/all/v/63/p/last%2024/c315/7169,1,2,3,4,5,6,7,8,9"
  )
}
