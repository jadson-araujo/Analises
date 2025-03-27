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
DENGON2023 <- import("DENGON2023.xlsx")
# Importando a base de 2024 -----------------------------------------------
DENGON2024 <- import("DENGONSE37.xlsx")
# Importando tabela com os municípios do RN -------------------------------
MUNICIPIOS_PROCV <- import("municipios.xlsx")

# -------------------------------------------------------------------------
# Análise da base de dados de Dengue 
# -------------------------------------------------------------------------

# Criando bases de apoio ---------------------------------------------------

CLASSIFICACAO <- data.frame(
  CLASSI_FIN = c(0, 5, 8, 10, 11, 12, 13),
  CLASS = c('Ign/Branco', 'Descartado', 'Inconclusivo', 'Dengue',
               'Dengue com sinais de alarme', 'Dengue grave', 'Chikungunya'),
  stringsAsFactors = FALSE)

CRITERIO_ID <- data.frame(
  ID_CRITERIO = c('LABORATORIAL', 'CLÍNICO EPIDEMIOLÓGICO', 'EM INVESTIGAÇÃO'),
  CRITERIO = c('1', '2', '3'),
  stringsAsFactors = FALSE)

# -------------------------------------------------------------------------
# Distribuição de casos prováveis por SE de sintomas 2023
# -------------------------------------------------------------------------

DENGON2023 <- DENGON2023 |> 
  mutate(SE_SINTOMAS = epiweek(DT_SIN_PRI)) |>
  mutate(ANO_SINTOMAS = epiyear(DT_SIN_PRI))

DENGON2023 <- DENGON2023 |>
  filter(ANO_SINTOMAS == 2023)

DENGON2023 <- DENGON2023 |>
  mutate(across(CLASSI_FIN, ~ replace_na(as.double(.), 0)))

PROVAVEIS_2023 <- DENGON2023 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(ID_MN_RESI) |>
  summarise(CASOS = n(), .groups = 'drop')

# Filtra e transforma os dados
PROVAVEIS_2023 <- DENGON2023 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(ID_MN_RESI, SE_SINTOMAS) |>
  summarise(CASOS = n(), .groups = 'drop') |>
  pivot_wider(names_from = SE_SINTOMAS, values_from = CASOS, values_fill = list(CASOS = 0)) |>
  # Selecionar as semanas que serão incluídas nas prováveis
  select(ID_MN_RESI, all_of(as.character(1:36)))

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

# -------------------------------------------------------------------------
# Distribuição de casos prováveis por SE de sintomas 2024
# -------------------------------------------------------------------------

DENGON2024 <- DENGON2024 |> 
  mutate(SE_SINTOMAS = epiweek(DT_SIN_PRI)) |>
  mutate(ANO_SINTOMAS = epiyear(DT_SIN_PRI))

DENGON2024 <- DENGON2024 |>
  filter(ANO_SINTOMAS == 2024)

DENGON2024 <- DENGON2024 |>
  mutate(across(CLASSI_FIN, ~ replace_na(as.double(.), 0)))

PROVAVEIS_2024 <- DENGON2024 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(ID_MN_RESI) |>
  summarise(CASOS = n(), .groups = 'drop')

# Filtra e transforma os dados
PROVAVEIS_2024 <- DENGON2024 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(ID_MN_RESI, SE_SINTOMAS) |>
  summarise(CASOS = n(), .groups = 'drop') |>
  pivot_wider(names_from = SE_SINTOMAS, values_from = CASOS, values_fill = list(CASOS = 0)) |>
  # Selecionar as semanas que serão incluídas nas prováveis
  select(ID_MN_RESI, all_of(as.character(1:36)))

# Adicionar uma coluna com o total de casos por município
PROVAVEIS_2024 <- PROVAVEIS_2024 |>
  mutate(Total = rowSums(across(-ID_MN_RESI), na.rm = TRUE))

# Filtrar o DataFrame
PROVAVEIS_2024 <- PROVAVEIS_2024 |>
  filter(ID_MN_RESI %in% ID_MUN)

PROVAVEIS_2024 <- PROVAVEIS_2024 |>
  mutate(ID_MN_RESI = as.double(ID_MN_RESI))

PROVAVEIS_2024 <- PROVAVEIS_2024 |>
  left_join(MUNICIPIOS_PROCV, by = "ID_MN_RESI")

PROVAVEIS_2024 <- PROVAVEIS_2024 |>
  select(ID_MN_RESI, MUNICIPIO, REGIAO, everything())

# -------------------------------------------------------------------------
# Classificação -----------------------------------------------------------
# -------------------------------------------------------------------------

CLASSI_FINAL <- DENGON2024 |>
  mutate(CLASSI_FIN = ifelse(is.na(CLASSI_FIN), 0, CLASSI_FIN))

CLASSI_FINAL <- CLASSI_FINAL |>
  group_by(ID_MN_RESI, CLASSI_FIN) |>
  summarise(CASOS = n(), .groups = 'drop')

CLASSI_FINAL <- CLASSI_FINAL |>
  mutate(CLASSI_FIN = as.double(CLASSI_FIN))

CLASSI_FINAL <- CLASSI_FINAL |>
  left_join(CLASSIFICACAO, by = "CLASSI_FIN")

CLASS_MUN_RESID <- CLASSI_FINAL |>
  select(ID_MN_RESI, CLASS, CASOS) |>
  group_by(ID_MN_RESI) |>
  pivot_wider(names_from = CLASS, values_from = CASOS, values_fill = list(CASOS = 0))

CLASS_MUN_RESID <- CLASS_MUN_RESID %>%
  mutate(Provaveis = Dengue + `Dengue com sinais de alarme` + `Dengue grave` + Inconclusivo + `Ign/Branco`)

CLASS_MUN_RESID <- CLASS_MUN_RESID %>%
  mutate(Notificados = sum(Dengue, `Dengue com sinais de alarme`, `Dengue grave`, Inconclusivo, `Ign/Branco`, Descartado))

CLASS_MUN_RESID <- CLASS_MUN_RESID |>
  filter(ID_MN_RESI %in% ID_MUN)

# Criando as colunas de municipios e populacao ----------------------------
CLASS_MUN_RESID <- CLASS_MUN_RESID |>
  mutate(ID_MN_RESI = as.double(ID_MN_RESI))

CLASS_MUN_RESID <- CLASS_MUN_RESID |>
  left_join(MUNICIPIOS_PROCV, by = "ID_MN_RESI")

# Criando a coluna de casos confirmados na aba de classificação -----------
CLASS_MUN_RESID <- CLASS_MUN_RESID |>
  mutate(Confirmados = rowSums(across(c(Dengue, `Dengue com sinais de alarme`, `Dengue grave`)), na.rm = TRUE))

CLASS_MUN_RESID <- CLASS_MUN_RESID %>%
  mutate(Incidência = Provaveis / POPULAÇÃO * 100000)

CLASS_MUN_RESID <- CLASS_MUN_RESID |>
  select(ID_MN_RESI, REGIAO, MUNICIPIO, Descartado, `Ign/Branco`, Inconclusivo, everything())
         
CRITERIO_ENCERRAMENTO <- DENGON2024 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 0, CLASSI_FIN != 13)
                 
CRITERIO_ENCERRAMENTO <- CRITERIO_ENCERRAMENTO |>
  filter(ID_MN_RESI %in% ID_MUN) |>
  group_by(CRITERIO) |>
  summarise(ENCERRADOS = n(), .groups = 'drop')

CRITERIO_ENCERRAMENTO <- CRITERIO_ENCERRAMENTO |>
  left_join(CRITERIO_ID, by = "CRITERIO") |>
  select(ID_CRITERIO, ENCERRADOS)

INCIDENCIA_DENGUE_MAPA <- CLASS_MUN_RESID |>
  select(ID_MN_RESI, MUNICIPIO, Incidência)

# -------------------------------------------------- ----------------------
# Adicionando a página com os totais da classificação
# -------------------------------------------------- ----------------------

TOTAIS_DENGUE <- CLASS_MUN_RESID |>
  mutate(PROVAVEIS_TOTAL = sum(CLASS_MUN_RESID$Provaveis)) |>
  mutate(CONFIRMADOS_TOTAL = sum(CLASS_MUN_RESID$Confirmados)) |>
  mutate(DESCARTADOS_TOTAL = sum(CLASS_MUN_RESID$Descartado)) |>
  mutate(NOTIFICADOS_TOTAL = sum(CLASS_MUN_RESID$Notificados)) |>
  mutate(INCIDÊNCIA_TOTAL = PROVAVEIS_TOTAL/3560903*100000)

TOTAIS_DENGUE <- TOTAIS_DENGUE |>
  select(NOTIFICADOS_TOTAL, DESCARTADOS_TOTAL, PROVAVEIS_TOTAL, 
         CONFIRMADOS_TOTAL, INCIDÊNCIA_TOTAL) |>
  filter(ID_MN_RESI == "240010")

TOTAIS_DENGUE <- TOTAIS_DENGUE |>
  pivot_longer(cols = NOTIFICADOS_TOTAL:INCIDÊNCIA_TOTAL, 
               names_to = "Tipo", 
               values_to = "Valor")

TOTAIS_DENGUE <- TOTAIS_DENGUE |>
  group_by(Tipo) |>
  summarise(Valor = Valor, .groups = 'drop')

# -------------------------------------------------- ----------------------
# Adicionando a distribuição por sorotipos
# -------------------------------------------------- ----------------------

# SOROTIPO <- DENGON2024 |>
#   group_by(SOROTIPO) |>
#   summarise(qtd = n(), .groups = 'drop')

# -------------------------------------------------- ----------------------
# Adicionando os dados do GAL ---------------------------------------------
# -------------------------------------------------- ----------------------

gal_dengue_1a3 <- import("Dengue GAL 01a03.xlsx")
gal_dengue_4a6 <- import("Dengue GAL 04a06.xlsx")
gal_dengue_7a9 <- import("Dengue GAL 07a09.xlsx")
gal_dengue_10a12 <- import("Dengue GAL 10a12.xlsx")

gal_dengue_1a3 <- subset(gal_dengue_1a3, `Data da Solicitação` >= as.Date("2024-01-01")) 

gal_dengue_1a3 <- gal_dengue_1a3 %>%
  mutate(`Requisição` = as.numeric(`Requisição`))

gal_dengue_4a6 <- gal_dengue_4a6 %>%
  mutate(`Requisição` = as.numeric(`Requisição`))

gal_dengue_combined <- rbind(gal_dengue_1a3, gal_dengue_4a6, gal_dengue_7a9, gal_dengue_10a12)

gal_dengue_metodologia <- gal_dengue_combined |>
  group_by(Exame, `1º Campo Resultado`) |>
  summarise(ENCERRADOS = n(), .groups = 'drop')

gal_dengue_metodologia <- gal_dengue_metodologia |>
  filter(`1º Campo Resultado` != "Resultado: Indeterminado", `1º Campo Resultado` != "Resultado: Inconclusivo")

# -------------------------------------------------- ----------------------
# Adicionando as datas como páginas na planilha
# -------------------------------------------------- ----------------------

tb_dengue <- createWorkbook()

addWorksheet(tb_dengue, sheetName = "Prováveis2023")
writeData(tb_dengue, sheet = "Prováveis2023", x = PROVAVEIS_2023)

addWorksheet(tb_dengue, sheetName = "Prováveis2024")
writeData(tb_dengue, sheet = "Prováveis2024", x = PROVAVEIS_2024)

addWorksheet(tb_dengue, sheetName = "Classificação")
writeData(tb_dengue, sheet = "Classificação", x = CLASS_MUN_RESID)

addWorksheet(tb_dengue, sheetName = "Critérios de encerramento")
writeData(tb_dengue, sheet = "Critérios de encerramento", x = CRITERIO_ENCERRAMENTO)

addWorksheet(tb_dengue, sheetName = "Totais para classificação")
writeData(tb_dengue, sheet = "Totais para classificação", x = TOTAIS_DENGUE)

addWorksheet(tb_dengue, sheetName = "GAL")
writeData(tb_dengue, sheet = "GAL", x = gal_dengue_metodologia)

saveWorkbook(tb_dengue, "PLANILHA_DENGON2024.xlsx", overwrite = TRUE)

# -------------------------------------------------- ----------------------
# Arquivo .csv para mapa
# -------------------------------------------------- ----------------------

tb_dengue1 <- createWorkbook()

addWorksheet(tb_dengue1, sheetName = "INCIDÊNCIA")
writeData(tb_dengue1, sheet = "INCIDÊNCIA", x = INCIDENCIA_DENGUE_MAPA)

saveWorkbook(tb_dengue1, "INCIDÊNCIA_DENGUE_MAPA.csv", overwrite = TRUE)