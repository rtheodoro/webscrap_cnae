################################################################################.
#                0_webscrap_CNAE
#
# Objetivo:
#          Acessar o site do IBGE e baixar as CNAE, com todas as
#          NOTAS EXPLICATIVAS, contendo Seção, Divisão, Grupo, Classe e
#          Subclasse
#
# Autor: Ricardo Theodoro
#
#
################################################################################.

# Rodando os scripts em sequência
source("1_webscrap_CNAE_secao.R")
source("2_webscrap_CNAE_divisao.R")
source("3_webscrap_CNAE_grupo.R")
source("4_webscrap_CNAE_classe.R")
source("5_webscrap_CNAE_subclasse.R")



