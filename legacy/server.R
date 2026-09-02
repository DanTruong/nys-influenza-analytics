# Load requisite libraries
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

server <- function(input, output, session) {
  # Define map as a Leaflet component
  output$map <- renderLeaflet({

    # Init Leaflet
    leaflet() %>%

      # Add map tiles from Mapbox
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%

      # Set default map view over Syracuse, NY
      setView(lng = -76.1474, lat = 43.0481, zoom = 7) %>%

      # Draw circles to represent flu incidents
      addCircles(
        data = fluDataCons[
          fluDataCons$Year == as.integer(input$yearVal) &
          fluDataCons$Month == as.integer(input$monthVal) &
          fluDataCons$Disease == trimws(input$diseaseVal),
        ],
        lat = ~Latitude,
        lng = ~Longitude,
        radius = ~ Incidents * 50,
        color = 'red',
        popup = ~ as.character(paste0(
          County,
          " County: ",
          Incidents,
          " Flu Cases"
        )),
        label = ~ as.character(paste0(
          County,
          " County: ",
          Incidents, 
          " Flu Cases"
        ))
      )
  })

  # Define table to include consolidated dataset
  output$incTable <- DT::renderDataTable(fluDataCons)
}

