library(shiny)
library(leaflet)

## Load the data set with meteorological events. Code to construct it is in "Create_data_set.R"
dataEvents <- read.table("Events_Data_Set.txt")


## Shiny UI
navbarPage(
   title = 'Data Products',
   tabPanel('Meteorological events', 
            pageWithSidebar(
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
            )
      ),
   tabPanel('Documentation', 
            headerPanel("Documentation on dynamic meteorological events in USA with Shiny and Leaflet"),
            mainPanel(
               p(
                  paste("The original data set is get from the National Weather Service Storm Data documentation.",
                        "The idea of the subject cam from the course \"Reproductible Research\" of John Hopkins.",
                        "Meteorological events from USA wil be displayed on a map of USA with Leaflet.",
                        "Types of events can be selected, dinamically filtering data with Shiny.",
                        "NB. : for Ease of reading, events are limited to 1000. This can be changed in the *server.R*."
                  )
               ),
               p("Documentation"),
               p("- Select the desired types of events on the next slide (tornados by default)"),
               p("- On the following slide, a map of USA appeared"),
               p("- Map is updated with selected types of events"),
               p("- Zoom to browse regions")
            )
   )
)
