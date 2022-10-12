################################################################################.
#                1_webscrap_CNAE_secao
#
# Objetivo:
#          Acessar o site do IBGE e baixar as CNAE, com todas as
#          NOTAS EXPLICATIVAS, contendo Seção
#
# Autor: Ricardo Theodoro
#
#
################################################################################.

# Acesso ao site ----
httr::handle_reset("https://cnae.ibge.gov.br")

cnae_secao <- data.frame(
  secao = as.character(),
  nome_secao = as.character(),
  divisao = as.character(),
  nome_divisao = as.character(),
  notas_explicativas = as.character()
)


for (i in 1:length(LETTERS)) {
  conexao <- httr::GET(
    paste0(
      "https://cnae.ibge.gov.br/?view=secao&tipo=cnae&versaosubclasse=10&versaoclasse=7&secao=",
      LETTERS[i],
      ""
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
  
  cat("Raspando seção", LETTERS[i], "\n")
  
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
    secao <- rep(cnae[1, 1] |> as.character(), nrow(cnae) - 3)
    nome_secao <- rep(cnae[2, 1] |> as.character(), nrow(cnae) - 3)
    divisao <- cnae[4:nrow(cnae), 1] |> unlist() |> as.character()
    divisao <- gsub("[^0-9.]", "", divisao)
    nome_divisao = gsub("[[:digit:]]", "", cnae[4:nrow(cnae), 1] |> unlist())
    nome_divisao = stringr::str_trim(nome_divisao)
    
    notas_explicativas <-
      conexao |>
      rvest::read_html() |>
      rvest::html_elements("table") |>
      rvest::html_nodes(xpath = '//*[@id="notas-explicativas"]') |>
      rvest::html_text2() |>
      rep(nrow(cnae) - 3)
    
    notas_explicativas <-
      stringr::str_remove_all(notas_explicativas, "[\r\n]")
    notas_explicativas <-
      stringr::str_remove_all(notas_explicativas, "Notas Explicativas:")
    
    
    cnae_secao_i <-
      cbind(secao,
            nome_secao,
            divisao,
            nome_divisao,
            notas_explicativas)
    
    cnae_secao <- rbind(cnae_secao, cnae_secao_i)
    
    rm(cnae_secao_i)
  }
}

write.csv(cnae_secao, "tabelas/1_cnae_secao.csv", row.names = FALSE)


rm(list = ls())
