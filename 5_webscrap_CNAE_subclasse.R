################################################################################.
#                5_webscrap_CNAE_subclasse
#
# Objetivo:
#          Acessar o site do IBGE e baixar as CNAE, com todas as
#          NOTAS EXPLICATIVAS, contendo Sub-classe
#
# Autor: Ricardo Theodoro
#
#
################################################################################.


# Acesso ao site ----
httr::handle_reset("https://cnae.ibge.gov.br")

cnae_subclasse <- data.frame(
  secao = as.character(),
  nome_secao = as.character(),
  divisao = as.character(),
  nome_divisao = as.character(),
  grupo = as.character(),
  nome_grupo = as.character(),
  classe = as.character(),
  nome_classe = as.character(),
  subclasse = as.character(),
  nome_subclasse = as.character(),
  notas_explicativas = as.character()
)


subclasses <- read.csv("tabelas/4_cnae_classe.csv") |>
  dplyr::select(subclasse) |>
  dplyr::mutate(subclasse = gsub("\\.", "", subclasse))

for (i in 1:nrow(subclasses)) {
  conexao <- httr::GET(
    paste0(
      "https://cnae.ibge.gov.br/?view=subclasse&tipo=cnae&versao=10&subclasse=",
      subclasses[i, ]
    ),
    httr::add_headers(
      "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
      "User-Agent" = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
      "Accept-Language" = "en-US,en;q=0.5",
      "Accept-Encoding" = "gzip, deflate, br",
      "DNT" = "1",
      "Connection" = "keep-alive",
      "Upgrade-Insecure-Requests" = "1",
      "Sec-Fetch-Dest" = "document",
      "Sec-Fetch-Mode" = "navigate",
      "Sec-Fetch-Site" = "none",
      "Sec-Fetch-User" = "?1",
      "Pragma" = "no-cache",
      "Cache-Control" = "no-cache"
    )
  )
  
  cat("Raspando classe",
      subclasses[i,],
      " - ",
      i,
      " de ",
      nrow(subclasses),
      "\n")
  
  cnae <- conexao |>
    rvest::read_html() |>
    rvest::html_element("table") |>
    rvest::html_text2() |>
    as.list() |>
    purrr::pluck(1) |>
    strsplit("\\r") |>
    unlist() |>
    tibble::as_tibble() |>
    dplyr::rename("secao" = "value") |>
    dplyr::filter(secao != " " & secao != "Seção:") |>
    dplyr::mutate(secao = stringr::str_trim(secao))
  
  if (dim(cnae)[1] < 3) {
    cat("Vazio \n")
    
  } else{
    secao <- cnae[1, 1] |> as.character() |> rep(nrow(cnae) - 9)
    nome_secao <-
      cnae[2, 1] |> as.character() |> rep(nrow(cnae) - 9)
    
    divisao <-
      cnae[4, 1] |> unlist() |> as.character() |> rep(nrow(cnae) - 9)
    divisao <- gsub("[^0-9.]", "", divisao)
    nome_divisao = gsub("[[:digit:]]", "", cnae[4, 1] |> unlist()) |> rep(nrow(cnae) - 9)
    nome_divisao = stringr::str_trim(nome_divisao)
    
    grupo <-
      cnae[6, 1] |> unlist() |> as.character() |> rep(nrow(cnae) - 9)
    grupo <- gsub("[^0-9.]", "", grupo)
    nome_grupo = gsub("[[:digit:]]", "", cnae[6, 1] |> unlist()) |> rep(nrow(cnae) - 9)
    nome_grupo = stringr::str_trim(nome_grupo)
    
    classe <-
      cnae[8, 1] |> unlist() |> as.character() |> rep(nrow(cnae) - 9)
    classe <- gsub("[^0-9.]", "", classe)
    nome_classe = gsub("[[:digit:]]", "", cnae[8, 1] |> unlist()) |> rep(nrow(cnae) - 9)
    nome_classe = stringr::str_trim(nome_classe)
    
    subclasse <-
      cnae[10:nrow(cnae), 1] |> unlist() |> as.character()
    subclasse <- gsub("[^0-9.]", "", subclasse)
    nome_subclasse = gsub("[[:digit:]]", "", cnae[10:nrow(cnae) , 1] |> unlist())
    nome_subclasse = stringr::str_trim(nome_subclasse)
    
    notas_explicativas <-
      conexao |>
      rvest::read_html() |>
      rvest::html_elements("table") |>
      rvest::html_nodes(xpath = '//*[@id="notas-explicativas"]') |>
      rvest::html_text2() |>
      rep(nrow(cnae) - 9)
    
    notas_explicativas <-
      stringr::str_remove_all(notas_explicativas, "[\r\n]")
    notas_explicativas <-
      stringr::str_remove_all(notas_explicativas, "Notas Explicativas:")
    
    
    cnae_subclasse_i <-
      cbind(
        secao,
        nome_secao,
        divisao,
        nome_divisao,
        grupo,
        nome_grupo,
        classe,
        nome_classe,
        subclasse,
        nome_subclasse,
        notas_explicativas
      )
    
    cnae_subclasse <- rbind(cnae_subclasse, cnae_subclasse_i)
    
    rm(cnae_subclasse_i)
  }
  
}

write.csv(cnae_subclasse, "tabelas/5_cnae_subclasse.csv", row.names = FALSE)

rm(list = ls())
