# Relatório IPCA

Relatório mensal automatizado do IPCA (Índice Nacional de Preços ao Consumidor Amplo), gerado com R e Quarto e publicado via Posit Connect Cloud.

O documento cobre variação mensal, acumulado em 12 meses versus meta do CMN, padrão sazonal desde 2015 e decomposição por grupos de despesa.

## Fontes de dados

| Série | Fonte | Conteúdo |
|-------|-------|----------|
| 433 | BCB/SGS via `rbcb` | IPCA — variação mensal |
| 13521 | BCB/SGS via `rbcb` | Meta de inflação anual (CMN) |
| Tabela 7060 | IBGE/SIDRA via `sidrar` | IPCA por grupos de despesa |

## Estrutura

```
.
├── R/
│   ├── coleta.R       # coleta via rbcb e sidrar
│   ├── tratamento.R   # transformações e agregações
│   └── graficos.R     # visualizações ggplot2
├── relatorio_ipca.qmd # documento principal
├── _quarto.yml        # configuração do projeto Quarto
└── README.md
```

## Pré-requisitos

- [R >= 4.4](https://cloud.r-project.org/)
- [Quarto >= 1.5](https://quarto.org/docs/download/)

Instale os pacotes R necessários:

```r
install.packages(c(
  "dplyr", "ggplot2", "lubridate", "scales", "stringr",
  "forcats", "slider", "tibble", "sidrar", "knitr", "rmarkdown"
))

# rbcb requer instalação via GitHub
install.packages("remotes")
remotes::install_github("wilsonfreitas/rbcb")
```

## Como rodar

Renderiza o relatório e gera `relatorio_ipca.html`:

```bash
quarto render relatorio_ipca.qmd
```

Para forçar re-execução completa do código R (ignorando o cache `_freeze/`):

```bash
quarto render relatorio_ipca.qmd --no-freeze
```

## Atualização mensal

O projeto usa `freeze: auto` — o Quarto só re-executa chunks cujo código mudou. Para atualizar os dados sem alterar o código, use `--no-freeze`.
