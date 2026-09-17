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
        #data = fluDataCons[
        #  fluDataCons$Year == as.integer(input$yearVal) &
        #  fluDataCons$Month == as.integer(input$monthVal) &
        #  fluDataCons$Disease == trimws(input$diseaseVal),
        #],
        #data = fluData[
        #  fluData$Season == input$seasonVal &
        #  fluData$Week == input$weekVal,
        #],
        data = aggregate(. ~ County + Latitude + Longitude, 
            fluDataFinal[
                fluDataFinal$Date >= as.Date(input$dateVal[1], format = "%Y-%m-%d") &
                fluDataFinal$Date <= as.Date(input$dateVal[2], format = "%Y-%m-%d"),   
            ], 
        sum),
        lat = ~Latitude,
        lng = ~Longitude,
        radius = ~ Incidents * 10,
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
      ) %>%
    
    addCircles(
      data = aggregate(. ~ County + Latitude + Longitude, 
        fluDataFinal[
              fluDataFinal$Date >= as.Date(input$dateVal[1], format = "%Y-%m-%d") &
              fluDataFinal$Date <= as.Date(input$dateVal[2], format = "%Y-%m-%d"),   
        ], 
        sum),
      lat = ~Latitude,
      lng = ~Longitude,
      radius = ~ ARIMA * 10,
      color = 'blue',
      popup = ~ as.character(paste0(
        County,
        " County: ",
        ARIMA,
        " Predicted Flu Cases (ARIMA)"
      )),
      label = ~ as.character(paste0(
        County,
        " County: ",
        ARIMA, 
        " Predicted Flu Cases (ARIMA)"
      ))
    ) %>%
      addCircles(
        data = aggregate(. ~ County + Latitude + Longitude, 
                         fluDataFinal[
                           fluDataFinal$Date >= as.Date(input$dateVal[1], format = "%Y-%m-%d") &
                             fluDataFinal$Date <= as.Date(input$dateVal[2], format = "%Y-%m-%d"),   
                           ], 
                         sum),
        lat = ~Latitude,
        lng = ~Longitude,
        radius = ~ HW * 10,
        color = 'green',
        popup = ~ as.character(paste0(
          County,
          " County: ",
          HW,
          " Predicted Flu Cases (Holt-Winters)"
        )),
        label = ~ as.character(paste0(
          County,
          " County: ",
          HW, 
          " Predicted Flu Cases (Holt-Winters)"
        ))
      )
  })

  # Define table to include consolidated dataset
  output$incTable <- DT::renderDataTable(fluDataFinal)
  
  output$predCenter <- renderPlot({
    ts.plot(ts(fluDataFinal$Incidents[fluDataFinal$County==input$countyVal & fluDataFinal$Date >= as.Date("2018-10-06", format = "%Y-%m-%d")], 
               frequency = 61, start = c(2018, 40)), 
            ts(fluDataFinal$ARIMA[fluDataFinal$County==input$countyVal & fluDataFinal$Date >= as.Date("2018-10-06", format = "%Y-%m-%d")], 
               frequency = 61, start = c(2018, 40)), 
            ts(fluDataFinal$HW[fluDataFinal$County==input$countyVal & fluDataFinal$Date >= as.Date("2018-10-06", format = "%Y-%m-%d")], 
               frequency = 61, start = c(2018, 40)), 
            gpars=list(xlab="Date", ylab="Flu Incidents", lty=c(1:3)))
  })
  
  output$mseArima <- renderText({
    mean(fluDataFinal$Error_ARIMA[fluDataFinal$County==input$countyVal & 
                                    fluDataFinal$Date >= as.Date("2018-10-06", format = "%Y-%m-%d")] ^ 2)
  })
  
  output$mseHW <- renderText({
    mean(fluDataFinal$Error_HW[fluDataFinal$County==input$countyVal & 
                                    fluDataFinal$Date >= as.Date("2018-10-06", format = "%Y-%m-%d")] ^ 2)
  })
}

