server <- function(input, output, session) {

  
  
  
  shinyalert(
    title = HTML("<span style = 'font-family:Manrope; font-size: 24px; font-weight:700;padding: 0px;color:#f39c1;'>ENTORNO URBANO 2020</span>"),
    text = HTML("<span style = 'font-family:Manrope; font-size: 14px; font-weight:400;padding: 0px;color:#f39c1;'>Tablero interactivo que muestra las características de entorno urbano de las manzanas que conforman las cabeceras municipales y las localidades de más de 2,500 habitantes en el estado de Sonora.</span>"),
    closeOnEsc = TRUE,
    closeOnClickOutside = FALSE,
    html = TRUE,
    type = "",
    showConfirmButton = TRUE,
    showCancelButton = FALSE,
    confirmButtonText =  "ENTRAR",
    confirmButtonCol = "#FD9D24",
    timer = 0,
    imageUrl = "https://raw.githubusercontent.com/ISAFdatos/Mapas-Colonias-Sonora/main/logos/isaf.png",
    imageWidth = 400,
    imageHeight = 100,
    animation = TRUE
  )
  
  loc_mun <- reactive({
    localidades %>%  
      filter(nom_mun==input$selMun) 
  })
  
  observe({
    updateSelectInput(session, "selLoc",
                      choices = loc_mun()$nom_loc)
  })
  
  output$barras <- renderPlotly({ 
    input$do
    gbarras <- isolate(grafico(x= input$selCort, y= input$selLoc, z=input$selMun))
    gbarras
  })
  
  output$mapas <- renderLeaflet({
    input$do
    gmapa <- isolate(mapa(x= input$selCort, y= input$selLoc, z=input$selMun))
    gmapa
    })
  
 output$loc_box <-  renderValueBox({
   input$do
    vloc<- isolate(valueBox(
      toupper(HTML(paste(strwrap(input$selLoc, width =15), collapse = "<br/>"))), color="yellow",subtitle = paste0(input$selMun, ", 2020"), icon("building")))
    vloc
  })

 
 output$hab_box <- renderValueBox({
   input$do
   isolate ({
   pobloc <- loc_mun() %>% filter(nom_loc==input$selLoc)
   vhab <- valueBox(paste0( prettyNum(as.numeric(pobloc$pobtot), big.mark=",", preserve.width="none")), color="yellow",subtitle =  "habitantes", icon("users"))
   })
   vhab
 })
 
 
 output$manzanas_box <- renderValueBox({
   input$do
   isolate ({
     locmun <- loc_mun() %>% filter(nom_loc==input$selLoc)
   vmanz <- valueBox(paste0( prettyNum(as.numeric(locmun$manzanas), big.mark=",", preserve.width="none")), color="yellow",subtitle = "manzanas", icon("th-large"))
   })
   vmanz
 })
 
 output$caract <- renderText({
   input$do 
   isolate ({
   cort <- toupper(input$selCort)
   })
   cort
   })

 o <- observe({
   shinyjs::click("do")
   o$destroy() # destroy observer as it has no use after initial button click
 })
 

}