# Carregando as bibliotecas necessárias
install.packages("shiny")
install.packages("ggplot2")
install.packages("DT")
install.packages("leaflet")
library(shiny)
library(ggplot2)
library(DT)
library(leaflet)

# Definindo o UI (User Interface)
ui <- fluidPage(
  
  # Título do aplicativo
  titlePanel("Exemplo Completo de Interface Shiny"),
  
  # Layout com abas
  tabsetPanel(
    # Aba 1: Inputs e gráficos
    tabPanel("Gráficos", 
             
             sidebarLayout(
               sidebarPanel(
                 sliderInput("num", "Número de pontos", min = 10, max = 100, value = 50),
                 selectInput("color", "Escolha a cor do gráfico", choices = c("red", "blue", "green", "purple")),
                 actionButton("update", "Atualizar Gráfico")
               ),
               mainPanel(
                 plotOutput("scatterPlot"),
                 textOutput("selected_points")
               )
             )
    ),
    
    # Aba 2: Tabelas e dados
    tabPanel("Tabelas", 
             DTOutput("dataTable")
    ),
    
    # Aba 3: Texto dinâmico e inputs
    tabPanel("Texto Dinâmico", 
             textInput("name", "Qual seu nome?", value = ""),
             actionButton("greetButton", "Saudar"),
             verbatimTextOutput("greeting")
    ),
    
    # Aba 4: Barra de progresso
    tabPanel("Progresso", 
             actionButton("startProgress", "Iniciar Progresso"),
             textOutput("progressStatus"),
             plotOutput("progressPlot")
    ),
    
    # Aba 5: Mapa Interativo
    tabPanel("Mapa Interativo", 
             leafletOutput("map", height = 600)  # Exibição do mapa
    )
  )
)

# Definindo o Server (Lógica de reatividade)
server <- function(input, output, session) {
  
  # Exemplo de gráfico de dispersão
  output$scatterPlot <- renderPlot({
    input$update  # Acionar renderização apenas quando o botão for pressionado
    x <- rnorm(input$num)
    y <- rnorm(input$num)
    
    ggplot(data.frame(x, y), aes(x, y)) +
      geom_point(color = input$color) +
      theme_minimal() +
      labs(title = "Gráfico de Dispersão")
  })
  
  # Exibindo o número de pontos selecionados no gráfico
  output$selected_points <- renderText({
    paste("Número de pontos selecionados:", input$num)
  })
  
  # Exibindo uma tabela com o dataset mtcars
  output$dataTable <- renderDT({
    datatable(mtcars)
  })
  
  # Exibindo mensagem de saudação com base no input do usuário
  observeEvent(input$greetButton, {
    output$greeting <- renderText({
      paste("Olá, ", input$name, "!", sep = "")
    })
  })
  
  # Exemplo de barra de progresso
  observeEvent(input$startProgress, {
    withProgress(message = 'Processando...', value = 0, {
      for(i in 1:100) {
        Sys.sleep(0.1)
        incProgress(1/100)
      }
    })
    
    output$progressStatus <- renderText({
      "Processo concluído!"
    })
    
    output$progressPlot <- renderPlot({
      plot(1:10, 1:10, main = "Progresso Concluído", col = "green", pch = 16)
    })
  })
  
  # Renderizando o mapa Leaflet
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%  # Adiciona o mapa base
      setView(lng = -51.9253, lat = -14.2350, zoom = 4) %>%  # Define a visão inicial do mapa (centro do Brasil)
      addMarkers(lng = -51.9253, lat = -14.2350, popup = "Centro do Brasil")
  })
}

# Rodando o aplicativo
shinyApp(ui = ui, server = server)
