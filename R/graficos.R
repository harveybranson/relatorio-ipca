COR_PRINCIPAL <- "#282f6b"
COR_META      <- "#2ca25f"
COR_NEGATIVO  <- "#d73027"

tema_ipca <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(face = "bold"),
      axis.title       = ggplot2::element_text(size = 10),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position  = "bottom"
    )
}

grafico_ipca_mensal <- function(ipca_raw) {
  dados <- ipca_raw |>
    dplyr::arrange(date) |>
    dplyr::slice_tail(n = 24) |>
    dplyr::mutate(cor = ifelse(ipca_mm >= 0, COR_PRINCIPAL, COR_NEGATIVO))

  ggplot2::ggplot(dados, ggplot2::aes(x = date, y = ipca_mm, fill = cor)) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_date(date_labels = "%b\n%Y", date_breaks = "3 months") +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = "%", decimal.mark = ",")
    ) +
    ggplot2::labs(x = NULL, y = "Variação mensal (%)") +
    tema_ipca()
}

grafico_ipca_12m <- function(ipca_meta) {
  ggplot2::ggplot(ipca_meta, ggplot2::aes(x = date)) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = meta_inflacao - 1.5, ymax = meta_inflacao + 1.5),
      fill = COR_META, alpha = 0.15
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = meta_inflacao),
      color = COR_META, linetype = "dashed", linewidth = 0.8
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = ipca_12m),
      color = COR_PRINCIPAL, linewidth = 1
    ) +
    ggplot2::scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = "%", decimal.mark = ",")
    ) +
    ggplot2::labs(x = NULL, y = "Acumulado 12 meses (%)") +
    tema_ipca()
}

grafico_sazonal <- function(ipca_saz) {
  ano_corrente <- max(ipca_saz$ano)
  dados_hist   <- dplyr::filter(ipca_saz, ano != ano_corrente)
  dados_atu    <- dplyr::filter(ipca_saz, ano == ano_corrente)

  ggplot2::ggplot() +
    ggplot2::geom_line(
      data = dados_hist,
      ggplot2::aes(x = mes, y = ipca_mm, group = ano),
      color = "gray70", linewidth = 0.4, alpha = 0.7
    ) +
    ggplot2::geom_line(
      data = dados_atu,
      ggplot2::aes(x = mes, y = ipca_mm),
      color = COR_PRINCIPAL, linewidth = 1.2
    ) +
    ggplot2::scale_x_continuous(
      breaks = 1:12,
      labels = c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
                 "Jul", "Ago", "Set", "Out", "Nov", "Dez")
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::label_number(suffix = "%", decimal.mark = ",")
    ) +
    ggplot2::labs(x = NULL, y = "Variação mensal (%)") +
    tema_ipca()
}

grafico_contribuicoes <- function(contrib_mes) {
  dados <- contrib_mes |>
    dplyr::filter(!is.na(contribuicao), !is.na(grupo)) |>
    dplyr::mutate(
      grupo = forcats::fct_reorder(grupo, contribuicao),
      cor   = ifelse(contribuicao >= 0, COR_PRINCIPAL, COR_NEGATIVO)
    )

  ggplot2::ggplot(dados, ggplot2::aes(x = contribuicao, y = grupo, fill = cor)) +
    ggplot2::geom_col(show.legend = FALSE) +
    ggplot2::geom_vline(xintercept = 0, linewidth = 0.3) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(
      labels = scales::label_number(suffix = " p.p.", decimal.mark = ",")
    ) +
    ggplot2::labs(x = "Contribuição (p.p.)", y = NULL) +
    tema_ipca()
}
