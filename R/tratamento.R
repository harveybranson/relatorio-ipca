calcular_acumulado_12m <- function(ipca_raw) {
  ipca_raw |>
    dplyr::arrange(date) |>
    dplyr::mutate(
      ipca_12m = slider::slide_dbl(
        ipca_mm,
        ~ (prod(1 + .x / 100) - 1) * 100,
        .before = 11,
        .complete = TRUE
      )
    ) |>
    dplyr::filter(!is.na(ipca_12m))
}

calcular_acumulado_ano <- function(ipca_raw) {
  ipca_raw |>
    dplyr::arrange(date) |>
    dplyr::mutate(ano = lubridate::year(date)) |>
    dplyr::group_by(ano) |>
    dplyr::mutate(
      ipca_ano = (cumprod(1 + ipca_mm / 100) - 1) * 100
    ) |>
    dplyr::ungroup()
}

preparar_meta_mensal <- function(ipca_12m, meta_raw) {
  meta_anual <- meta_raw |>
    dplyr::mutate(ano = lubridate::year(date)) |>
    dplyr::group_by(ano) |>
    dplyr::summarise(meta_inflacao = dplyr::last(meta_inflacao), .groups = "drop")

  ipca_12m |>
    dplyr::mutate(ano = lubridate::year(date)) |>
    dplyr::left_join(meta_anual, by = "ano") |>
    dplyr::select(-ano)
}

preparar_sazonal <- function(ipca_raw, ano_inicio = 2015) {
  ipca_raw |>
    dplyr::filter(lubridate::year(date) >= ano_inicio) |>
    dplyr::mutate(
      ano = lubridate::year(date),
      mes = lubridate::month(date)
    )
}

preparar_contribuicoes <- function(grupos_raw) {
  codigos <- tibble::tibble(
    codigo = c("1", "2", "3", "4", "5", "6", "7", "8", "9"),
    grupo  = c(
      "Alimentação e bebidas", "Habitação", "Artigos de residência",
      "Vestuário", "Transportes", "Saúde e cuidados pessoais",
      "Despesas pessoais", "Educação", "Comunicação"
    ),
    peso = c(26.0, 14.1, 4.4, 5.4, 20.5, 13.2, 8.1, 6.1, 2.2)
  )

  col_valor  <- "Valor"
  col_mes    <- "Mês (Código)"
  col_codigo <- "Geral, grupo, subgrupo, item e subitem (Código)"

  dados <- grupos_raw |>
    dplyr::rename(
      valor   = dplyr::all_of(col_valor),
      mes_cod = dplyr::all_of(col_mes),
      codigo  = dplyr::all_of(col_codigo)
    ) |>
    dplyr::mutate(codigo = as.character(codigo)) |>
    dplyr::filter(codigo != "7169") |>
    dplyr::mutate(
      date     = lubridate::ym(mes_cod),
      variacao = suppressWarnings(as.numeric(valor))
    ) |>
    dplyr::filter(!is.na(variacao)) |>
    dplyr::select(date, codigo, variacao) |>
    dplyr::left_join(codigos, by = "codigo") |>
    dplyr::mutate(contribuicao = variacao * peso / 100)

  list(
    mes_atual  = dplyr::filter(dados, date == max(date, na.rm = TRUE)),
    historico  = dados
  )
}
