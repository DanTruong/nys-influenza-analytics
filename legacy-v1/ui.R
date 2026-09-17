# Load requisite libraries
library(leaflet)

ui <- navbarPage("NYS Influenza Map",
  id = "nav",

  tabPanel("Map", div(
    class = "outer", tags$head(
      includeCSS("styles.css"),
      includeScript("gomap.js")
    ),

    leafletOutput("map",
      width = "100%",
      height = "100%"
    ),

    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = 60,
      left = "auto",
      right = 20,
      bottom = "auto",
      width = 330,
      height = "auto",
      h2("Data Variables"),
      #selectInput("seasonVal", "Season", unique(fluData$Season)),
      #selectInput("weekVal", "Week", head(unique(fluData$Week), -2))
      dateRangeInput("dateVal", "Date Range",
                     min = min(as.Date(fluDataFinal$Date, format = "%Y-%m-%d")),
                     max = max(as.Date(fluDataFinal$Date, format = "%Y-%m-%d")),
                     start  = min(as.Date(fluDataFinal$Date, format = "%Y-%m-%d")),
                     end = min(as.Date(fluDataFinal$Date, format = "%Y-%m-%d")) + 365,
                     format = "mm/dd/yy",
                     separator = " - "),
      h4("Red = Actual Values"),
      h4("Blue = ARIMA Est. Values"),
      h4("Green = Holt-Winters Est. Values"),
    ),
  )),

  tabPanel("Data", DT::dataTableOutput("incTable")),
  
  tabPanel("2018-2019 Predictions", div(
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      #top = 60,
      top = "auto",
      left = "auto",
      right = 20,
      bottom = 20,
      width = 330,
      height = "auto",
      h2("Data Variables"),
      selectInput("countyVal", "County", unique(fluDataFinal$County)),
      h4("Dashed line represents ARIMA forecasted predictions. Dotted line represent Holt-Winters predictions.")
    ),
    
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = "auto",
      left = 20,
      right = "auto",
      bottom = 20,
      width = 300,
      height = "auto",
      h2("Mean Squared Error (ARIMA)"),
      textOutput("mseArima")
    ),
    
    absolutePanel(
      id = "controls",
      class = "panel panel-default",
      fixed = TRUE,
      draggable = TRUE,
      top = "auto",
      left = 320,
      right = "auto",
      bottom = 20,
      width = 300,
      height = "auto",
      h2("Mean Squared Error (Holt-Winters)"),
      textOutput("mseHW")
    ),
    
    plotOutput("predCenter", click = "plot_click")
  )),

  conditionalPanel("false", icon("crosshair"))
)
