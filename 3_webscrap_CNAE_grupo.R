################################################################################.
#                3_webscrap_CNAE_grupo
#
# Objetivo:
#          Acessar o site do IBGE e baixar as CNAE, com todas as
#          NOTAS EXPLICATIVAS, contendo Grupo
#
# Autor: Ricardo Theodoro
#
#
################################################################################.

# Acesso ao site ----
httr::handle_reset("https://cnae.ibge.gov.br")

cnae_grupo <- data.frame(
  secao = as.character(),
  nome_secao = as.character(),
  divisao = as.character(),
  nome_divisao = as.character(),
  grupo = as.character(),
  nome_grupo = as.character(),
  classe = as.character(),
  nome_classe = as.character(),
  notas_explicativas = as.character()
)

grupo <- read.csv("tabelas/2_cnae_divisao.csv") |>
  dplyr::select(grupo) |>
  dplyr::mutate(grupo = as.character(grupo),
                grupo = gsub("\\.", "", grupo))

for (i in 1:nrow(grupo)) {

  conexao <- httr::GET(
    ifelse(
     as.numeric(grupo[i,]) < 100,
      paste0(
        "https://cnae.ibge.gov.br/?view=grupo&tipo=cnae&versao=10&grupo=0",
        grupo[i,],
        ""
      ),
      paste0(
        "https://cnae.ibge.gov.br/?view=grupo&tipo=cnae&versao=10&grupo=",
        grupo[i,],
        ""
      )
      
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
  
  cat("Raspando grupo", as.numeric(grupo[i,]), "\n")
  
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
  
  if (dim(cnae)[1] == 0) {
    cat("Vazio \n")
  } else{
    secao <- cnae[1, 1] |> as.character() |> rep(nrow(cnae) - 7)
    nome_secao <-
      cnae[2, 1] |> as.character() |> rep(nrow(cnae) - 7)
    divisao <-
      cnae[4, 1] |> unlist() |> as.character() |> rep(nrow(cnae) - 7)
    divisao <- gsub("[^0-9.]", "", divisao)
    nome_divisao = gsub("[[:digit:]]", "", cnae[4, 1] |> unlist()) |> rep(nrow(cnae) - 7)
    nome_divisao = stringr::str_trim(nome_divisao)
    grupo <-
      cnae[6, 1] |> unlist() |> as.character() |> rep(nrow(cnae) - 7)
    grupo <- gsub("[^0-9.]", "", grupo)
    nome_grupo = gsub("[[:digit:]]", "", cnae[6, 1] |> unlist()) |> rep(nrow(cnae) - 7)
    nome_grupo = stringr::str_trim(nome_grupo)
    classe <- cnae[8:nrow(cnae), 1] |> unlist() |> as.character()
    classe <- gsub("[^0-9.]", "", classe) # Não pega o 0 depois do traço
    nome_classe = gsub("[[:digit:]]", "", cnae[8:nrow(cnae) , 1] |> unlist())
    nome_classe = stringr::str_trim(nome_classe)
    
    notas_explicativas <-
      conexao |>
      rvest::read_html() |>
      rvest::html_elements("table") |>
      rvest::html_nodes(xpath = '//*[@id="notas-explicativas"]') |>
      rvest::html_text2() |>
      rep(nrow(cnae) - 7)
    
    notas_explicativas <-
      stringr::str_remove_all(notas_explicativas, "[\r\n]")
    notas_explicativas <-
      stringr::str_remove_all(notas_explicativas, "Notas Explicativas:")
    
    
    cnae_grupo_i <-
      cbind(
        secao,
        nome_secao,
        divisao,
        nome_divisao,
        grupo,
        nome_grupo,
        classe,
        nome_classe,
        notas_explicativas
      )
    
    cnae_grupo <- rbind(cnae_grupo, cnae_grupo_i)
    
    rm(cnae_grupo_i)
  }
  
}

write.csv(cnae_grupo, "tabelas/3_cnae_grupo.csv", row.names = FALSE)

rm(list = ls())
