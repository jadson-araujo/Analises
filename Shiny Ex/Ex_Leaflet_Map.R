library(leaflet)
library(bit64)
library(epitools)
library(tidyverse)
library(janitor)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(tidyr)

setwd("C:\\Users\\Jadson Raphael\\Documents\\Analises\\dados")

unidades_hospitalares <- data.frame(
  unidade_hospitalar = c(
    "Hospital Monsenhor Walfredo Gurgel",
    "Hospital Dr Luiz Antônio",
    "Hospital Universitário Onofre Lopes",
    "Hospital João Machado",
    "Hospital Maria Alice Fernandes",
    "Hospital de Natal - Unidade São Lucas",
    "Hospital Santa Catarina",
    "Hospital Infantil Varela Santiago",
    "Hospital da Polícia Militar",
    "Hospital Ney Peixoto"
  ),
  lat = c(-5.7969638, -5.799303, -5.7976365, -5.7899, -5.8243, -5.7993, -5.8000, -5.8182, -5.8052, -5.8735),
  lng = c(-35.2110499, -35.221694, -35.213524, -35.2069, -35.2873, -35.1986, -35.2023, -35.2099, -35.2108, -35.3007)
)

# Criar o mapa
mapa_rn <- leaflet() %>%
  addTiles() %>%  # Adicionar o mapa base (OpenStreetMap)
  
  # Adicionar marcadores para cada unidade
  addMarkers(
    data = unidades_hospitalares,
    lng = unidades_hospitalares$lng,
    lat = unidades_hospitalares$lat,
    popup = unidades$unidade_hospitalar 
    )
    icon = makeIcon(
      iconUrl = "https://png.pngtree.com/png-vector/20220623/ourmid/pngtree-location-pin-marker-placeholder-my-png-image_5289012.png",  # URL da imagem do ícone
      iconWidth = 32,  # Largura do ícone
      iconHeight = 32,  # Altura do ícone
      iconAnchorX = 16,  # Posição do ponto de ancoragem do ícone
      iconAnchorY = 32   # Posição do ponto de ancoragem do ícone
    )

# Mostrar o mapa
mapa_rn

