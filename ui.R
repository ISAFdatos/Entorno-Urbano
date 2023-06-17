source("global.R")


ui <- tagList(dashboardPage(
  skin = "yellow-light", 
  md = TRUE, 


  dashboardHeader(title=h1("ENTORNO URBANO 2020", style = "font-family: Manrope;font-weight: 900; color: white; margin-left:0px; font-size:20px !important;"),
                  titleWidth = 300
                  ),

  dashboardSidebar(width = 150, minified = F,
                   br(),br(),br(),br(),
                   sidebarMenu(
                   menuItem(HTML("<span style = 'font-family:Manrope; font-size: 20px; font-weight:700;padding: 0px;color:#f39c1;'> TABLERO</span>"), 
                            icon = icon("bar-chart"), tabName = "dashboard"),
                   br(),br(),br(),
                   menuItem(HTML("<span style = 'font-family:Manrope; font-size: 20px; font-weight:700;padding: 0px;color:#f39c1;'> NOTAS</span>"), 
                            icon = icon("file-text"), tabName = "notas")
                   )
                   ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    tabItems(
      tabItem(tabName = "dashboard",
    column(2,
           fluidRow(
    wellPanel(style="background-color: white;", height="100vh", 
              br(),br(),
    p(tags$img(
      src = "https://www.un.org/sustainabledevelopment/wp-content/uploads/sites/3/2019/09/S_SDG_Icons_Inverted_Transparent_WEB-11-400x400.png",
      alt = "ODS 11",
      width = 210,
      height = 210,
      
    ), style="text-align: center;"),

    selectizeInput("selMun", label = "Municipio:", choices = sort(unique(localidades$nom_mun)), selected="Aconchi"),
    selectizeInput("selLoc", label = "Localidad:", choices = "", selected="Aconchi"),
    selectizeInput("selCort", label = "Característica urbana:", choices = unique(texto$nom_cort), selected="Pavimentación"),
    br(),br(),
    fluidRow(
      column(12,
    div(style="display:inline-block;width:100%;text-align: center;", 
        shinyWidgets::actionBttn(inputId="do", label=HTML("<span style = 'font-family:Manrope; font-size: 18px; font-weight:700;'>GRAFICAR</span>"), style="fill",
                 color="warning"
                 )
    )
      )
    ),
    br(), br(),
    
    p(tags$img(
      src = "https://raw.githubusercontent.com/ISAFdatos/Mapas-Colonias-Sonora/main/logos/ISAF%20ODS%20color.png",
      alt = "ODS 11",
      width = 210
      
    ), style="text-align: center;",
    br(),br(),br(),br(),br()
    )))),
    
    column(3,
    fluidRow(
            valueBoxOutput("loc_box", width=12),
            valueBoxOutput("hab_box", width=12),
            valueBoxOutput("manzanas_box", width=12),
    
    box(title=HTML(paste0("<span style = 'font-family:Manrope; font-size: 18px; font-weight:600; padding: 0px;'>", textOutput("caract")),"</span>"),
        footer=HTML("<span style = 'font-family:Manrope; font-size: 12px; font-weight:400;padding: 0px;'>Fuente: INEGI (2020)</span>"), 
        status="warning",headerBorder = FALSE, solidHeader = TRUE, style="border: 0px",
        width = 12,
            plotlyOutput("barras",height="32vh")
           ))),
  column(7,
         fluidRow(
         wellPanel(style="background-color: white;",
                   shinycssloaders::withSpinner(leafletOutput("mapas",height="82vh"),type = 7, color = "#FD9D24" )
           )
         )
  
)
),
tabItem(tabName = "notas",
        column(1),
        column(9,
        wellPanel(style="background-color: white;",
        includeHTML("www/datos/introduccion_ods11.html")
        )
        ),
        column(2, wellPanel(style="position: sticky; background-color: white;",
                            br(),br(),
                            p(tags$img(
                              src = "https://www.un.org/sustainabledevelopment/es/wp-content/uploads/sites/3/2019/09/S-WEB-Goal-11.png",
                              alt = "ODS 11",
                              width = 160,
                              height = 160,
                              
                            ), style="text-align: center;"),    
                            br(), br(),
                            
                            p(tags$img(
                              src = "https://raw.githubusercontent.com/ISAFdatos/Mapas-Colonias-Sonora/main/logos/ISAF%20ODS%20color.png",
                              alt = "ODS 11",
                              width = 160
                              
                            ), style="text-align: center;"),
                            br(),br()
        )) 
)
    )
  )
),

tags$footer("ISAF SONORA (2023)", align = "center", style = "
              position:fixed;
              bottom:0;
              width:100%;
              height:25px;   /* Height of the footer */
              color: white;
              padding: 5px;
              font-weight: 400;
              font-family: Manrope !important;
              background-color: #FD9D24;
              font-size: 12px;
              z-index: 1000;")

)
