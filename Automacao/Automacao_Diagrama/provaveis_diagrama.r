library(dplyr)
library(epitools)
library(tidyverse)
library(janitor)
library(rio)
library(lubridate)
library(tidyr)
library(readr)
library(openxlsx)

DENGON <- import("DENGON.dbf")

# -------------------------------------------------------------------------
# Análise da base de dados de Dengue 
# -------------------------------------------------------------------------

# Criando bases de apoio ---------------------------------------------------

CLASSIFICACAO <- data.frame(
  CLASSI_FIN = c(0, 5, 8, 10, 11, 12, 13),
  CLASS = c('Ign/Branco', 'Descartado', 'Inconclusivo', 'Dengue',
               'Dengue com sinais de alarme', 'Dengue grave', 'Chikungunya'),
  stringsAsFactors = FALSE)

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
  summarise(CASOS = n(), .groups = 'drop')

tb_dengue <- createWorkbook()

addWorksheet(tb_dengue, sheetName = "Prováveis")
writeData(tb_dengue, sheet = "Prováveis", x = PROVAVEIS)

saveWorkbook(tb_dengue, "PARA O DIAGRAMA.xlsx", overwrite = TRUE)


