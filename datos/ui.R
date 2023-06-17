source("global.R")

includeCSS("www/style.css")

ui <- dashboardPage(
  tags$style(HTML("div.sticky {
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  z-index: 1;
}")),
  skin = "yellow-light", md = TRUE, 

  dashboardHeader(title=h1("ENTORNO URBANO 2020", style = "font-family: Manrope;font-weight: 900; color: white; margin-left:0px; font-size:22px !important"),
                  titleWidth = 300),

  dashboardSidebar(width = 300,
                   br(), 
                   minified = F,
                   p(tags$img(
                     src = "https://www.un.org/sustainabledevelopment/wp-content/uploads/sites/3/2019/09/S_SDG_Icons_Inverted_Transparent_WEB-11-400x400.png",
                     alt = "ODS 11",
                     width = 210,
                     height = 210,
                     
                   ), style="text-align: center;"),
                   
                   selectizeInput("selMun", label = "Municipio:", choices = sort(unique(localidades$nom_mun)), selected="Aconchi"),
                   selectizeInput("selLoc", label = "Localidad:", choices = "", selected="Aconchi"),
                   selectizeInput("selCort", label = "Característica urbana:", choices = unique(texto$nom_cort), selected="Pavimentación"),
                   br(),
                   actionButton("do", "GRAFICAR", style="text-align: center;"),
                   br(),
                   
                   br(),br(),
                   p(tags$img(
                     src = "https://raw.githubusercontent.com/ISAFdatos/Mapas-Colonias-Sonora/main/logos/ISAF%20ODS%20color.png",
                     alt = "ODS 11",
                     width = 210
                     
                   ), style="text-align: center;")

    
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    
    column(4,
    fluidRow(
            valueBoxOutput("loc_box", width=12),
            valueBoxOutput("hab_box", width=12),
            valueBoxOutput("manzanas_box", width=12),
    ),
    wellPanel(style="background-color: white",
            plotlyOutput("barras",height="35vh")
           )),
  column(8,
         fluidRow(
         wellPanel(style="background-color: white",
                   shinycssloaders::withSpinner(leafletOutput("mapas",height="85vh"),type = 7, color = "#FD9D24" )
           )
         )
  
)
)
)
