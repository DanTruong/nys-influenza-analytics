# Load requisite libraries
library(dplyr)
library(plyr)
library(tidyr)

# Load in dataset file
rawData <- read.csv("data/fluData.csv")

# Select specific columns to work with
fluData <- data.frame(
  County = rawData$County, 
  Date = rawData$Week.Ending.Date,
  Disease = rawData$Disease, 
  Incidents = as.integer(rawData$Count), 
  Coordinates = rawData$County.Centroid
)

# Split coordinates into Longitude/Latitude (Double)
fluData <- fluData %>% separate(Coordinates, c("Latitude", "Longitude"), ", ")
fluData$Latitude <- substring(fluData$Latitude, first = 2)
fluData$Longitude <- substring(fluData$Longitude, 1, nchar(fluData$Longitude) -
  1)
fluData$Latitude <- as.double(fluData$Latitude)
fluData$Longitude <- as.double(fluData$Longitude)

# Separate date into Month, Day and Year (Integer)
fluData <- fluData %>% separate(Date, 
                                sep = "/", 
                                into = c("Month", "Day", "Year"))
fluData$Month <- as.integer(fluData$Month)
fluData$Day <- as.integer(fluData$Day)
fluData$Year <- as.integer(fluData$Year)

# Rename Influenza Labels
fluData$Disease <- revalue(fluData$Disease, c(
  INFLUENZA_A = "A", 
  INFLUENZA_B = "B",
  INFLUENZA_UNSPECIFIED = "Unspecified"
))

# Aggregate flu data by sum of incidents
fluDataCons <- fluData[-c(3)]
fluDataCons <- aggregate(Incidents ~ ., fluDataCons, sum)
