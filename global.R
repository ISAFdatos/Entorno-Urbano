library(shinyalert)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(janitor)
library(sf)
library(ggspatial)
library(rgdal)
library(shiny)
library(shinycssloaders)
library(htmltools)
library(htmlwidgets)
library(leaflet)
library(leaflet.extras)
library(leafem)
library(plotly)
library(lubridate)
library(scales)


tema <- theme(
  legend.position = "none",
  panel.background = element_blank(),
  axis.text.y = element_text(family = "Manrope", size = 12, color = "black"),
  axis.text.x = element_blank(),
  panel.grid.major.y = element_blank(), 
  panel.grid.minor.y = element_blank(),
  panel.grid.major.x = element_blank(),
  panel.grid.minor.x = element_blank(),
  plot.title = element_text(family = "Manrope Extrabold", size = 10, color = "black"),
  axis.line = element_blank(),
  plot.title.position = "plot",
  axis.title = element_text(family = "Manrope", size = 12)) 


fondo <- "white"
texto <- read_csv("www/datos/nombres calle 2020.csv")  


titulo <- "Poppins ExtraBold"
negrita <- "Manrope Extrabold"
ligera <- "Manrope Light"
grafico <- "Roboto Condensed"

paleta <- c(  "#FD9D24","#72bcd5",  "#376795", "gray85" )

ramp <-  c("3","2","1", "NA")

etiquetas <- c("Todas las\nvialidades","Alguna\nvialidad","Ninguna\nvialidad","No aplica-No especificado")


localidades <- read_csv("www/datos/localidades.csv", 
                        col_types = cols(cveloc = col_character())) 


t <- list(
  size = 12,
  family = "Manrope",
  color = "black")

lyo <- list(
  family = "Manrope",
  size = 13)

# x="Pavimentación"
# y="Hermosillo"
# z="Hermosillo"


grafico <- function(x=cort, y=loc, z=mun){
  
nombres  <- texto %>% filter(nom_cort==x)
locmun <- localidades %>% filter(nom_mun==z & nom_loc==y)

descarga <- paste0("https://raw.githubusercontent.com/ISAFdatos/Entorno-Urbano/main/mapas/",locmun$cveloc,"_",nombres$caract,"_2020.png")


sonmza <- readRDS(paste0("www/datos/municipios_rds/",locmun$nom_mun,"_caract.rds")) %>% 
  filter(cveloc == locmun$cveloc & caract==nombres$caract) 


nombres$subtitulo <- paste(strwrap(nombres$subtitulo, width = 60), collapse = "\n")
loc_aggr <- sonmza %>% 
  group_by(clasf_prop) %>% summarise(Manzanas=sum(num), Poblacion=sum(pobtot)) %>% 
  mutate(pctj=round(Manzanas*100/sum(Manzanas),0),
         Proporción=paste0(pctj,"%")) %>% 
  mutate(valor=case_when(clasf_prop=="Todas las\r\nvialidades"~ 3,
                         clasf_prop=="Alguna\r\nvialidad"~ 2,
                         clasf_prop=="Ninguna\r\nvialidad"~ 1)) %>% 
  mutate(clasf_prop= fct_reorder(clasf_prop, valor, .desc = FALSE))

colors <- c("Todas las\r\nvialidades" = "#FD9D24","Alguna\r\nvialidad"="#72bcd5",  "Ninguna\r\nvialidad"= "#376795")

caractG <- ggplot(loc_aggr ) +
  geom_col(aes(x= clasf_prop, y= pctj, fill=clasf_prop, text=paste0(prettyNum(loc_aggr$Manzanas,big.mark = ","), " manzanas<br>",prettyNum(loc_aggr$Poblacion,big.mark = ",")," habs." )), linetype= "solid", size=1, width = .4)+
  geom_text(aes(x= clasf_prop, y= pctj+15, label=Proporción, color=clasf_prop), family="Manrope" ) +
  scale_fill_manual(name="", values= colors) +
  scale_color_manual(name="", values= colors) +
  theme_minimal() +
  scale_y_continuous(limits=c(0,125)) +
  tema +
  labs(y = NULL, x = NULL, fill = NULL, title = NULL ) +
  coord_flip() 


ggplotly(caractG, tooltip = "text") %>%
  layout(font=lyo, showlegend = FALSE, title = list(text =paste0("<b>", nombres$subtitulo,"</b>"), font=t,  x = 0, xanchor = 'left'),
         hoverlabel= list(font = list(family = 'Manrope',
                                      weight=500,
                             size = 15, color = 'white')),
         annotations = list(x = 1, y = 0, 
                            text = paste0("<br><br><a href = '",descarga,"'>Descarga este mapa</a>"),
                            xref='paper', yref='paper', showarrow = F, font=t,
                            xanchor='right', yanchor='auto', xshift=0, yshift=0,
                            font = list(size = 15))) %>%  
  config(displaylogo = FALSE,
         modeBarButtonsToRemove = list(
           'sendDataToCloud',
           'toImage',
           'pan2d',
           'lasso2d',
           'hoverClosestCartesian',
           'hoverCompareCartesian',
           'toggleSpikelines',
           'select2d',
           'zoomIn2d',
           'zoomOut2d',
           'resetScale2d'
         ))
}


mapa <- function(x=cort, y=loc, z=mun){

  nombres  <- texto %>% filter(nom_cort==x)
  locmun <- localidades %>% filter(nom_mun==z & nom_loc==y)
  
  sonmza <- readRDS(paste0("www/datos/municipios_rds/",locmun$nom_mun,"_caract.rds")) %>% 
    filter(cveloc == locmun$cveloc & caract==nombres$caract) 
  
  
  centrocol <- readr::read_csv_chunked("www/datos/centrocol.csv", 
                                       callback = DataFrameCallback$new(function(x, pos) subset(x, cveloc == locmun$cveloc))) 
  
  
  capa_mz <- st_read("www/shapes/26m.gpkg")  %>% 
    clean_names() %>%  merge(sonmza)   # Se incorpora la información censal al shape de colonias
  
  
  capa_mz <- st_transform(capa_mz, crs = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")) %>% 
    st_make_valid()
  
  
  
  balpal <-  colorFactor(c( "#FD9D24","#72bcd5",  "#376795"), levels= c("1","2","3"), na.color ="gray85")
  
  labs <- c("Todas las\nvialidades","Alguna\nvialidad","Ninguna\nvialidad")
  
  
  
  popup <- paste0("<span style = 'font-family:Manrope; font-size: 13px; border-color:rgba(0,0,0,0); color:#734001'>",
    "<strong>", "Municipio: ",        "</strong>",   (z) ,     "<br>",
    "<strong>", "Localidad: ",        "</strong>",   (y) ,     "<br>",
    "<strong>", "Colonia: ",        "</strong>",   (capa_mz$nom_col) ,     "<br>",
    "<strong>", "Manzana: ",        "</strong>",   capa_mz$cve_ageb, capa_mz$cve_mza ,     "<br>",
    "<strong>", "Habitantes: ",           "</strong>",   prettyNum(capa_mz$pobtot, big.mark=","),     "<br>", 
    "<strong>", x, ": ",          "</strong>",   as.character(capa_mz$clasf_prop),    "</span><br>")  %>% lapply(htmltools::HTML)
  
  label <- paste0(
    "<strong>", capa_mz$nom_col, " ", capa_mz$cve_ageb, capa_mz$cve_mza ,    "</strong>",   "<br>")  %>% lapply(htmltools::HTML)
  labelcol <- paste0(
    "<strong>",  centrocol$nom_col, "</strong>",   "<br>")  %>% lapply(htmltools::HTML)
  
  
  leaflet(capa_mz, options = leafletOptions(zoomControl = FALSE)) %>% 
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircles(data=centrocol, ~lon, ~lat, label = ~nom_col, color="transparent",
               labelOptions = labelOptions(noHide = F, direction = "top",
                                           style = list(
                                             "color" = "#734001",
                                             "font-family" = "Manrope",
                                             "font-style" = "regular",
                                             "box-shadow" = "2px 2px rgba(0,0,0,0.25)",
                                             "font-size" = "13px",
                                             "border-color" = "rgba(0,0,0,0.5)"
                                           )), 
               group= "COLONIAS") %>% 
    addPolygons(data= capa_mz,
                stroke= TRUE,
                weight=1.2,                   
                opacity=1,
                fillColor = ~balpal(capa_mz$valor),
                color= "transparent",
                fillOpacity = 1,
                smoothFactor = 0.5,
                highlightOptions = highlightOptions(color = "#734001", 
                                                    weight = 1.2,
                                                    bringToFront = TRUE),
                popup=popup,
                popupOptions = labelOptions(noHide = F, direction = "top", 
                                            closeOnClick = TRUE, 
                                            style = list(
                                              "color" = "black",
                                              "font-family" = "Manrope",
                                              "font-style" = "regular",
                                              "box-shadow" = "2px 2px rgba(0,0,0,0.25)",
                                              "font-size" = "13px",
                                              "border-color" = "rgba(0,0,0,0.5)"
                                            )),
                label=label,
                labelOptions = labelOptions(noHide = F, direction = "top",
                                            style = list(
                                              "color" = "#734001",
                                              "font-family" = "Manrope",
                                              "font-style" = "regular",
                                              "box-shadow" = "2px 2px rgba(0,0,0,0.25)",
                                              "font-size" = "13px",
                                              "border-color" = "rgba(0,0,0,0.5)"
                                            )),
                group= "ENTORNO URBANO") %>%
    addSearchFeatures(targetGroups= "COLONIAS", options = searchFeaturesOptions(zoom=15, openPopup=FALSE,moveToLocation=TRUE,
                                                                                firstTipSubmit = TRUE,
                                                                                autoCollapse = TRUE, hideMarkerOnCollapse = TRUE)) %>% 
    # setView(lng=coord$lon, lat=coord$lat, zoom=coord$zoom+1) %>% 
    onRender(
      "function(el, x) {
          L.control.zoom({
            position:'bottomright'
          }).addTo(this);
        }") 

}


