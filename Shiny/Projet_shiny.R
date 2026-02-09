
library(shiny)
library(tidyverse)

# Charger les données
shark <- read_csv2("global-shark-attack.csv")

# Liste de tous les pays
tous_pays <- shark %>%
  count(Country, sort = TRUE) %>%
  pull(Country)  #créer un vecteur des pays qui sera utilisé dans la liste déroualnte

# Definie l'interface utilisateur
ui <- fluidPage(

#Créer une interface personnalisé avec des cartes 
  tags$head(
    tags$style(HTML("
    body {
      background-color: #f2f2f2;
    }

    .main-header {
      background-color: #2c3e50;
      color: white;
      padding: 15px;
      margin-bottom: 20px;
      text-align: center;
    }

    .card {
      background-color: white;
      padding: 15px;
      margin-bottom: 15px;
      border: 1px solid #ddd;}"))),
  
  #Organisation de la page 
  
  fluidRow(
    
    # Partie filtrage des données séléectionnées
    
    column(3, div(class = "card", h4("Filtres"),  #On crée un bloc auquel on applique un sous-titre
               selectInput( 
                 "pays",
                 "Pays :",
                 choices = tous_pays,
                 selected = c("USA", "AUSTRALIA", "SOUTH AFRICA"),
                 multiple = TRUE),
               
  #Input sous forme de bouton coulissant 
  
               sliderInput(   
                 "annees",
                 "Période :",
                 min = min(shark$Year),
                 max = max(shark$Year),
                 value = c(1990, 2020),  #définir les limites du curseur 
                 sep = ""))), 
    
    # Partie Grpahiques : 
    column(9,div(class = "card", # column 9/12 : largeur 
               h4("Évolution du nombre d'attaques"),
               plotOutput("graphique")),
           
           div(class = "card",
               h4("Comparaison par pays"),
               plotOutput("comparaison")))))

  # Données filtrées
  donnees <- reactive(
    filter(shark,
      Country %in% input$pays,
      between(Year, input$annees[1], input$annees[2])))
  
  
  # Définition de la logique de l'application : graphiques 
  
  server <- function(input, output) {
    
    donnees <- reactive(filter(shark, Country %in% input$pays, #reactive : crée un objet qui se met à jour automatiquement (filtres : pays et période séléctionnés)
        between(Year, input$annees[1], input$annees[2])))
    
    # Graphique 1 : évolution des attaques
    output$graphique <- renderPlot({
      donnees() %>%
        count(Year, Country) %>% #nombre attaque par année et pays
        ggplot(aes(x = Year, y = n, color = Country)) +
        geom_line() +
        geom_point() +   #graphique en lignes (une couleur par pays)
        labs(x = "Année",y = "Nombre d'attaques") +  #labels
        theme_minimal()})
    
    # Graphique 2 : diagramme de comparaison (inspiré de l'analyse R)
    output$comparaison <- renderPlot({
      donnees() %>%
        mutate(Fatal_label = ifelse(Fatal == "Y", "Mortel", "Non mortel")) %>%
        count(Country, Fatal_label) %>%
        ggplot(aes(x = Country, y = n, fill = Fatal_label)) +
        geom_col() +
        labs(x = "", y = "Nombre d'attaques", fill = "Type d'attaque") +
        theme_minimal() })}

#Connecté l'interface et le serveur + lancer l'application 
shinyApp(ui = ui, server = server)