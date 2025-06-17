library(epitools)
library(tidyverse)
library(janitor)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(tidyr)

setwd("C:\\Users\\Jadson Raphael\\Documents\\Analises\\dados_gal_dcz")

dengue1a3 <- import("Dengue GAL 01a03.xlsx")
dengue4a6 <- import("Dengue GAL 04a06.xlsx")
dengue7a9 <- import("Dengue GAL 07a09.xlsx")
dengue10a12 <- import("Dengue GAL 10a12.xlsx")
GAL_COMPLETO <- rbind(dengue1a3, dengue4a6, dengue7a9, dengue10a12)
GAL_COMPLETO <- GAL_COMPLETO |>
  filter(`Data da Solicitação` == 2024)

# Insira o id dos municípios que serão considerados para o relatório
MUN <- c(240800, 240940)

RELATORIO_DENGUE <- GAL_COMPLETO |> 
  filter(`IBGE Município de Residência` %in% MUN)

RELATORIO_DENGUE <- RELATORIO_DENGUE |> 
  group_by(`Municipio de Residência` ,Exame, `1º Campo Resultado`) |>
  summarise(Qtd = n(), .groups = 'drop')

#-------------------------------------------------------------------------------

chik1a3 <- import("Chik GAL 1a3.xlsx")
chik4a6 <- import("Chik GAL 4a6.xlsx")
chik7a9 <- import("Chik GAL 7a9.xlsx")
chik10a12 <- import("Chik GAL 10a12.xlsx")
GAL_COMPLETO <- rbind(chik1a3, chik4a6, chik7a9, chik10a12)

RELATORIO_CHIK <- GAL_COMPLETO |> 
  filter(`IBGE Município de Residência` %in% MUN)

RELATORIO_CHIK <- RELATORIO_CHIK |> 
  group_by(`Municipio de Residência` ,Exame, `1º Campo Resultado`) |>
  summarise(Qtd = n(), .groups = 'drop')

#-------------------------------------------------------------------------------

zika1a3 <- import("Zika GAL 1a3.xlsx")
zika4a6 <- import("Zika GAL 4a6.xlsx")
zika7a9 <- import("Zika GAL 7a9.xlsx")
zika10a12 <- import("Zika GAL 10a12.xlsx")
GAL_COMPLETO <- rbind(zika1a3, zika4a6, zika7a9, zika10a12)

RELATORIO_ZIKA <- GAL_COMPLETO |> 
  filter(`IBGE Município de Residência` %in% MUN)

RELATORIO_ZIKA <- RELATORIO_ZIKA |> 
  group_by(`Municipio de Residência` ,Exame, `1º Campo Resultado`) |>
  summarise(Qtd = n(), .groups = 'drop')