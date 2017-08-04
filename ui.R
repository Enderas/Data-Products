library(shiny)
library(leaflet)

## Load the data set with meteorological events. Code to construct it is in "Create_data_set.R"
dataEvents <- read.table("Events_Data_Set.txt")


## Shiny UI
shinyUI(pageWithSidebar(
   headerPanel("Meteorological events in USA"),
   sidebarPanel(
      checkboxGroupInput("idTypeEvents", "Type of event",
                         levels(dataEvents$EVTYPE),
                         selected = "TORNADO"),
      width = 2
   ),
   mainPanel(
      leafletOutput('leafletEvents')
   )
))
