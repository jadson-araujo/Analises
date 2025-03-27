library(dplyr)
library(epitools)
library(tidyverse)
library(janitor)
library(rio)
library(openxlsx)
library(lubridate)
library(tidyr)
library(readr)

# Importando a base de 2024 -----------------------------------------------
DENGON2024 <- import("DENGON2024.dbf")
# Importando a base de 2024 -----------------------------------------------
DENGON2025 <- import("DENGON2025.dbf")
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

DENGON2024 <- DENGON2024 |> 
  mutate(SE_SINTOMAS = epiweek(DT_SIN_PRI)) |>
  mutate(ANO_SINTOMAS = epiyear(DT_SIN_PRI)) |>
  filter(ANO_SINTOMAS == 2024)

DENGON2025 <- DENGON2025 |> 
  mutate(SE_SINTOMAS = epiweek(DT_SIN_PRI)) |>
  mutate(ANO_SINTOMAS = epiyear(DT_SIN_PRI)) |>
  filter(ANO_SINTOMAS == 2025)

# -------------------------------------------------------------------------
# Distribuição de casos prováveis por SE de sintomas 2024
# -------------------------------------------------------------------------
DENGON2024 <- DENGON2024 |>
  mutate(across(CLASSI_FIN, ~ replace_na(as.double(.), 0)))

# Filtra e transforma os dados
PROVAVEIS_2024 <- DENGON2024 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(SE_SINTOMAS) |>
  summarise(Provaveis = n(), .groups = 'drop')

# -------------------------------------------------------------------------
# Distribuição de casos prováveis por SE de sintomas 2025
# -------------------------------------------------------------------------
DENGON2025 <- DENGON2025 |>
  mutate(across(CLASSI_FIN, ~ replace_na(as.double(.), 0)))

# Filtra e transforma os dados
PROVAVEIS_2025 <- DENGON2025 |>
  filter(CLASSI_FIN != 5, CLASSI_FIN != 13) |>
  group_by(SE_SINTOMAS) |>
  summarise(Provaveis = n(), .groups = 'drop')

# Classificação das notificações para o ano de 2025
CLASSI_FINAL <- DENGON2025 |>
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
  select(MUNICIPIO, Provaveis, Confirmados, Incidência, POPULAÇÃO, Descartado, Notificados) |>
  filter(MUNICIPIO != is.na(MUNICIPIO))

# Criando o arquivo que irá ser anexado no email para envio
tb_dengue <- createWorkbook()

addWorksheet(tb_dengue, sheetName = "Prováveis 2024")
writeData(tb_dengue, sheet = "Prováveis 2024", x = PROVAVEIS_2024)

addWorksheet(tb_dengue, sheetName = "Prováveis 2025")
writeData(tb_dengue, sheet = "Prováveis 2025", x = PROVAVEIS_2025)

addWorksheet(tb_dengue, sheetName = "Classificação")
writeData(tb_dengue, sheet = "Classificação", x = CLASS_MUN_RESID)

saveWorkbook(tb_dengue, "TABULACAO.xlsx", overwrite = TRUE)

