library(epitools)
library(tidyverse)
library(janitor)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(tidyr)

setwd("C:\\Users\\Jadson Raphael\\Documents\\Analises\\dados")

# Importando a base de 2023 -----------------------------------------------
ZIKA2023 <- import("NINDINET.dbf")
# Importando a base de 2024 -----------------------------------------------
ZIKA2024 <- import("NINDINET.dbf")
# Importando tabela com os municípios do RN -------------------------------
MUNICIPIOS_PROCV <- import("municipios.xlsx")

# -------------------------------------------------------------------------
# Análise da base de dados de Zika
# -------------------------------------------------------------------------

# Criando bases de apoio ---------------------------------------------------
CLASSIFICACAO <- data.frame(
  CLASSI_FIN = c(1, 2, 8, 0),
  CLASS = c('Confirmado', 'Descartado', 'Inconclusivo', 'Ign/Branco'),
  stringsAsFactors = FALSE)

CRITERIO_ID <- data.frame(
  ID_CRITERIO = c('LABORATORIAL', 'CLÍNICO EPIDEMIOLÓGICO'),
  CRITERIO = c('1', '2'),
  stringsAsFactors = FALSE)

# Aplicando os filtros na base NINDINET 2023X2024
ZIKA2023 <- ZIKA2023 |>
  filter(ID_AGRAVO == "A928")

ZIKA2023 <- ZIKA2023 |> 
  mutate(SE_SINTOMAS = epiweek(DT_SIN_PRI)) |>
  mutate(ANO_SINTOMAS = epiyear(DT_SIN_PRI))

ZIKA2023 <- ZIKA2023 |>
  filter(ANO_SINTOMAS == 2023)

ZIKA2023 <- ZIKA2023 |>
  mutate(across(CLASSI_FIN, ~ replace_na(as.double(.), 0)))

# Filtra e transforma os dados

PROVAVEIS_2023 <- ZIKA2023 |>
  filter(CLASSI_FIN != 2) |>
  group_by(ID_MN_RESI, SE_SINTOMAS) |>
  summarise(CASOS = n(), .groups = 'drop') |>
  pivot_wider(names_from = SE_SINTOMAS, values_from = CASOS, values_fill = list(CASOS = 0)) |>
  # Selecionar as semanas que serão incluídas nas prováveis
  select(ID_MN_RESI, all_of(as.character(1:20)))

# Adicionar uma coluna com o total de casos por município
PROVAVEIS_2023 <- PROVAVEIS_2023 |>
  mutate(Total = rowSums(across(-ID_MN_RESI), na.rm = TRUE))

# Lista de valores a serem filtrados
ID_MUN <- c( 240010, 240020, 240030, 240040, 240050, 240060, 240070, 240080, 240090, 240100, 
             240110, 240120, 240130, 240140, 240145, 240150, 240160, 240165, 240170, 240180, 
             240185, 240190, 240200, 240210, 240220, 240230, 240240, 240250, 240260, 240270, 
             240280, 240290, 240300, 240310, 240320, 240330, 240340, 240350, 240360, 240370, 
             240375, 240380, 240390, 240400, 240410, 240420, 240430, 240440, 240450, 240460, 
             240470, 240480, 240485, 240490, 240500, 240510, 240520, 240530, 240540, 240550, 
             240560, 240570, 240580, 240590, 240600, 240610, 240615, 240620, 240630, 240640, 
             240650, 240660, 240670, 240680, 240690, 240700, 240710, 240720, 240725, 240730, 
             240740, 240750, 240760, 240770, 240780, 240790, 240800, 240810, 240820, 240830, 
             240840, 240850, 240860, 240870, 240880, 240890, 240325, 240910, 240920, 240930, 
             240940, 240950, 240960, 240970, 240980, 240990, 241000, 241010, 241020, 241025, 
             241030, 241040, 241050, 241060, 241070, 241080, 241090, 240895, 241100, 241110, 
             241120, 240933, 241140, 241142, 241150, 241160, 241170, 241180, 241190, 241200, 
             241210, 241220, 241230, 241240, 241250, 241255, 241260, 241270, 241280, 241290, 
             241300, 241310, 241320, 241330, 241335, 241340, 241350, 241355, 241360, 241370, 
             241380, 241390, 241400, 241410, 241415, 241105, 241420, 241430, 241440, 241445, 
             241450, 241460, 241470, 241475, 241480, 241490, 241500)

# Filtrar o DataFrame
PROVAVEIS_2023 <- PROVAVEIS_2023 |>
  filter(ID_MN_RESI %in% ID_MUN)

PROVAVEIS_2023 <- PROVAVEIS_2023 |>
  mutate(ID_MN_RESI = as.double(ID_MN_RESI))

PROVAVEIS_2023 <- PROVAVEIS_2023 |>
  left_join(MUNICIPIOS_PROCV, by = "ID_MN_RESI")

PROVAVEIS_2023 <- PROVAVEIS_2023 |>
  select(ID_MN_RESI, MUNICIPIO, REGIAO, everything())


