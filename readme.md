# Webscrap CNAE - Notas Explicativas

Este projeto tem objetivo de fazer o download das Notas Explicativas das CNAE (Classificação Nacional de Atividade Econômica) disponíveis no site do [CONCLA - IBGE](https://cnae.ibge.gov.br/).

## Scripts e Pastas

O script `0_webscrap_CNAE.R` irá rodar os outros scripts, em que cada um deles irá fazer a raspagem de uma parte da estrutura da CNAE, sendo elas: seção, divisão, grupo, classe e sub-classe.

As tabelas salvas estão na pasta `tabelas` no formato .csv.

## TO-DO

- Fiz esse script rápido e ainda não tive tempo de lapidar ele. Provavelmente existe uma forma mais eficiente de fazer o que fiz aqui.

  - Acredito que exista um padrão para fazer tudo em um loop só, mas não tive tempo de pensar melhor nisso.

- É preciso ainda tratar algumas colunas de algumas tabelas, em que os nomes começam com pontos, traços, etc.

- É possível adicionar, também, a `Lista de Descritores` junto das classes e subclasses.

## Autor

[Ricardo Theodoro](https://www.linkedin.com/in/rtheodoro/)
[OBSCOOP/USP](https://linktr.ee/obscoopusp)
