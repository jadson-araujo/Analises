library(dplyr)
library(epitools)
library(tidyverse)
library(janitor)
library(rio)
library(lubridate)
library(tidyr)
library(readr)
library(openxlsx)

#setwd("Caminho para o diretório de trabalho")

DENGON <- import("DENGON.dbf")

# Análise da base de dados de Dengue
# ----------------------------------
# Criando bases de apoio

CLASSIFICACAO <- data.frame(
  CLASSI_FIN = c(0, 5, 8, 10, 11, 12, 13),
  CLASS = c('Ign/Branco', 'Descartado', 'Inconclusivo', 'Dengue',
               'Dengue com sinais de alarme', 'Dengue grave', 'Chikungunya'),
  stringsAsFactors = FALSE)

DENGON <- DENGON |> 
  mutate(SE_SINTOMAS = epiweek(DT_SIN_PRI)) |>
  mutate(ANO_SINTOMAS = epiyear(DT_SIN_PRI))

DENGON <- DENGON |>
  filter(ANO_SINTOMAS == 2025)

DENGON <- DENGON |>
  mutate(across(CLASSI_FIN, ~ replace_na(as.double(.), 0)))

PROVAVEIS <- DENGON |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(ID_MN_RESI) |>
  summarise(CASOS = n(), .groups = 'drop')

# Filtra e transforma os dados
PROVAVEIS <- DENGON |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(SE_SINTOMAS) |>
  summarise("2025" = n(), .groups = 'drop')

#--------------------------------------------------------------------
# Definição de situação com base na análise do diagrama de controle
#--------------------------------------------------------------------

DIAGRAMA <- DIAGRAMA |>
  left_join(PROVAVEIS, c("Sem.Epid.Sintomas" = "SE_SINTOMAS"))

ultima_semana <- max(which(!is.na(DIAGRAMA$"2025")))
valor_ult_se <- DIAGRAMA$`2025`[ultima_semana]

valor_mediana <- DIAGRAMA$MEDIANA[ultima_semana]

# Verificando a situação atual dos casos de dengue no estado
if (valor_ult_se > valor_mediana) {
  situacao <- "estamos acima da mediana" 
} else if (valor_ult_se == valor_mediana) {
  situacao <- "estamos com um número de casos equivalente a mediana"
} else {
  situacao <- "estamos abaixo da mediana"
}
# Salvando variáveis de apoio em formato txt para usar no corpo do e-mail
ultima_semana <- as.character(ultima_semana)
writeLines(ultima_semana, "ultima_semana.txt")
writeLines(situacao, "situacao.txt")

#--------------------------------------------------------------------

tb_dengue <- createWorkbook()

addWorksheet(tb_dengue, sheetName = "Prováveis")
writeData(tb_dengue, sheet = "Prováveis", x = PROVAVEIS)

saveWorkbook(tb_dengue, "PARA O DIAGRAMA.xlsx", overwrite = TRUE)


