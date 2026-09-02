# Load requisite libraries
library(dataMaid)

# Set short descriptions for each variable in consolidated flu dataset
attr(fluDataCons$County, "shortDescription") <- "NYS County where the data was collected"
attr(fluDataCons$Month, "shortDescription") <- "Month of occurrence recording"
attr(fluDataCons$Year, "shortDescription") <- "Year of occurrence recording"
attr(fluDataCons$Disease, "shortDescription") <- "Distinction of Influenza Type A, B or Unspecified"
attr(fluDataCons$Latitude, "shortDescription") <- "Latitude Coordinates of the County where the data was recorded"
attr(fluDataCons$Longitude, "shortDescription") <- "Longitude Coordinates of the County where the data was recorded"
attr(fluDataCons$Incidents, "shortDescription") <- "Amount of flu occurrences for the recorded month"

# Generate codebook for consolidated flu dataset
makeCodebook(fluDataCons, 
             reportTitle = "NYS Influenza Dataset - Monthly Consolidated 2010-2019",
             file = "codebook/codebook.Rmd")

