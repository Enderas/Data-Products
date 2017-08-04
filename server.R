library(shiny)
library(leaflet)
library(dplyr)

## Load the data set with meteorological events. Code to construct it is in "Create_data_set.R"
dataEvents <- read.table("Events_Data_Set.txt")

## Sample the data to be faster
dataEvents <- sample_n(dataEvents, 1000)

shinyServer(
   function(input, output) {
      output$leafletEvents <- renderLeaflet({
         # Filter data with selected values
         dataSelected <- filter(dataEvents, dataEvents$EVTYPE %in% input$idTypeEvents)
         
         # Format variables to Leaflet
         leafXY <- data.frame(lat = dataSelected$LATITUDE, lng = dataSelected$LONGITUDE)
         leafCol <- dataSelected$EVTYPE
         leafCol <- case_when(
            leafCol=="TORNADO"           ~ "orange",
            leafCol=="FLOOD"             ~ "red",
            leafCol=="HAIL"              ~ "blue",
            leafCol=="THUNDERSTORM WIND" ~ "green",
            leafCol=="TSTM WIND"         ~ "violet"
         )
         leafPopup <- paste("<B>", 
                            dataSelected$EVTYPE, "</B><BR />",
                            dataSelected$LATITUDE, "<BR />", 
                            dataSelected$LONGITUDE)
         
         # Leaflet map with markers on meteorological events
         leafXY %>%
            leaflet() %>%
            addTiles() %>%
            addCircleMarkers(col = leafCol, popup = leafPopup) %>%
            addLegend(labels = c("TORNADO", "FLOOD", "HAIL", "THUNDERSTORM WIND", "TSTM WIND"), colors = c("orange", "red", "blue", "green", "violet"))
      })
   }
)
