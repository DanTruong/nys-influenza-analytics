# Load requisite libraries
library(dplyr)
library(plyr)
library(tidyr)
library(forecast)
library(stats)
library(datasets)
library(dummies)
library(TTR)

# Load in dataset file
origin <- read.csv("data/fluData.csv")

# Custom function to "proper"-ize string values
proper <- function(s) sub("(.)", ("\\U\\1"), tolower(s), pe=TRUE)

# Extract locations data from origin
locations <- data.frame(
    County = proper(origin$County),
    Coordinates = origin$County.Centroid
)

## Remove duplicate rows
locations <- distinct(locations)

## Separate coordinates into lat/long
locations <- locations %>% separate(Coordinates, c("Latitude", "Longitude"), ", ")
locations$Latitude <- substring(locations$Latitude, first = 2)
locations$Longitude <- substring(locations$Longitude, 1, nchar(locations$Longitude) -
                                     1)
locations$Latitude <- as.double(locations$Latitude)
locations$Longitude <- as.double(locations$Longitude)

fluData <- origin[-c(2, 6, 8, 9)]
fluData$County <- proper(fluData$County)
names(fluData) <- c("Period", "County", "Week", "Date", "Incidents")
fluData$Date <- as.Date(fluData$Date, format = "%m/%d/%Y")
fluData <- aggregate(Incidents ~ ., fluData, sum)

trainingData <- fluData[fluData$Period != "2018-2019" & fluData$Period != "2019-2020", ]
testingData <- fluData[fluData$Period == "2018-2019" | fluData$Period == "2019-2020", ]


## County: Albany
countyName <- "Albany"
dataAlbany <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataAlbany <- rbind(dataAlbany, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataAlbany <- rbind(dataAlbany, pointer)
}
for(i in unique(dataAlbany$Period)){
    for(j in 21:39){
        dataDate <- dataAlbany$Date[dataAlbany$Week == j - 1 & dataAlbany$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataAlbany <- rbind(dataAlbany, pointer)
    }
}

## County: Allegany
countyName <- "Allegany"
dataAllegany <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataAllegany <- rbind(dataAllegany, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataAllegany <- rbind(dataAllegany, pointer)
}
for(i in unique(dataAllegany$Period)){
    for(j in 21:39){
        dataDate <- dataAllegany$Date[dataAllegany$Week == j - 1 & dataAllegany$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataAllegany <- rbind(dataAllegany, pointer)
    }
}

## County: Bronx
countyName <- "Bronx"
dataBronx <- trainingData[trainingData$County==countyName,]
for(i in unique(dataBronx$Period)){
    for(j in 21:39){
        dataDate <- dataBronx$Date[dataBronx$Week == j - 1 & dataBronx$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataBronx <- rbind(dataBronx, pointer)
    }
}

## County: Broome
countyName <- "Broome"
dataBroome <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataBroome <- rbind(dataBroome, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataBroome <- rbind(dataBroome, pointer)
}
for(i in unique(dataBroome$Period)){
    for(j in 21:39){
        dataDate <- dataBroome$Date[dataBroome$Week == j - 1 & dataBroome$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataBroome <- rbind(dataBroome, pointer)
    }
}

## County: Cattaraugus
countyName <- "Cattaraugus"
dataCattaraugus <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataCattaraugus <- rbind(dataCattaraugus, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataCattaraugus <- rbind(dataCattaraugus, pointer)
}
for(i in unique(dataCattaraugus$Period)){
    for(j in 21:39){
        dataDate <- dataCattaraugus$Date[dataCattaraugus$Week == j - 1 & dataCattaraugus$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataCattaraugus <- rbind(dataCattaraugus, pointer)
    }
}

## County: Cayuga
countyName <- "Cayuga"
dataCayuga <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataCayuga <- rbind(dataCayuga, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataCayuga <- rbind(dataCayuga, pointer)
}
for(i in unique(dataCayuga$Period)){
    for(j in 21:39){
        dataDate <- dataCayuga$Date[dataCayuga$Week == j - 1 & dataCayuga$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataCayuga <- rbind(dataCayuga, pointer)
    }
}

## County: Chautauqua
countyName <- "Chautauqua"
dataChautauqua <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataChautauqua <- rbind(dataChautauqua, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataChautauqua <- rbind(dataChautauqua, pointer)
}
for(i in unique(dataChautauqua$Period)){
    for(j in 21:39){
        dataDate <- dataChautauqua$Date[dataChautauqua$Week == j - 1 & dataChautauqua$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataChautauqua <- rbind(dataChautauqua, pointer)
    }
}

## County: Chemung
countyName <- "Chemung"
dataChemung <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataChemung <- rbind(dataChemung, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataChemung <- rbind(dataChemung, pointer)
}
for(i in unique(dataChemung$Period)){
    for(j in 21:39){
        dataDate <- dataChemung$Date[dataChemung$Week == j - 1 & dataChemung$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataChemung <- rbind(dataChemung, pointer)
    }
}

## County: Chenango
countyName <- "Chenango"
dataChenango <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataChenango <- rbind(dataChenango, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataChenango <- rbind(dataChenango, pointer)
}
for(i in unique(dataChenango$Period)){
    for(j in 21:39){
        dataDate <- dataChenango$Date[dataChenango$Week == j - 1 & dataChenango$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataChenango <- rbind(dataChenango, pointer)
    }
}

## County: Clinton
countyName <- "Clinton"
dataClinton <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataClinton <- rbind(dataClinton, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataClinton <- rbind(dataClinton, pointer)
}
for(i in unique(dataClinton$Period)){
    for(j in 21:39){
        dataDate <- dataClinton$Date[dataClinton$Week == j - 1 & dataClinton$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataClinton <- rbind(dataClinton, pointer)
    }
}

## County: Columbia
countyName <- "Columbia"
dataColumbia <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataColumbia <- rbind(dataColumbia, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataColumbia <- rbind(dataColumbia, pointer)
}
for(i in unique(dataColumbia$Period)){
    for(j in 21:39){
        dataDate <- dataColumbia$Date[dataColumbia$Week == j - 1 & dataColumbia$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataColumbia <- rbind(dataColumbia, pointer)
    }
}

## County: Cortland
countyName <- "Cortland"
dataCortland <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataCortland <- rbind(dataCortland, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataCortland <- rbind(dataCortland, pointer)
}
for(i in unique(dataCortland$Period)){
    for(j in 21:39){
        dataDate <- dataCortland$Date[dataCortland$Week == j - 1 & dataCortland$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataCortland <- rbind(dataCortland, pointer)
    }
}

## County: Delaware
countyName <- "Delaware"
dataDelaware <- trainingData[trainingData$County=="Delaware",]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataDelaware <- rbind(dataDelaware, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataDelaware <- rbind(dataDelaware, pointer)
}
for(i in unique(dataDelaware$Period)){
    for(j in 21:39){
        dataDate <- dataDelaware$Date[dataDelaware$Week == j - 1 & dataDelaware$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataDelaware <- rbind(dataDelaware, pointer)
    }
}

## County: Dutchess
countyName <- "Dutchess"
dataDutchess <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataDutchess <- rbind(dataDutchess, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataDutchess <- rbind(dataDutchess, pointer)
}
for(i in unique(dataDutchess$Period)){
    for(j in 21:39){
        dataDate <- dataDutchess$Date[dataDutchess$Week == j - 1 & dataDutchess$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataDutchess <- rbind(dataDutchess, pointer)
    }
}

## County: Erie
countyName <- "Erie"
dataErie <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataErie <- rbind(dataErie, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataErie <- rbind(dataErie, pointer)
}
for(i in unique(dataErie$Period)){
    for(j in 21:39){
        dataDate <- dataErie$Date[dataErie$Week == j - 1 & dataErie$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataErie <- rbind(dataErie, pointer)
    }
}

## County: Essex
countyName <- "Essex"
dataEssex <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataEssex <- rbind(dataEssex, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataEssex <- rbind(dataEssex, pointer)
}
for(i in unique(dataEssex$Period)){
    for(j in 21:39){
        dataDate <- dataEssex$Date[dataEssex$Week == j - 1 & dataEssex$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataEssex <- rbind(dataEssex, pointer)
    }
}

## County: Franklin
countyName <- "Franklin"
dataFranklin <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataFranklin <- rbind(dataFranklin, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataFranklin <- rbind(dataFranklin, pointer)
}
for(i in unique(dataFranklin$Period)){
    for(j in 21:39){
        dataDate <- dataFranklin$Date[dataFranklin$Week == j - 1 & dataFranklin$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataFranklin <- rbind(dataFranklin, pointer)
    }
}

## County: Fulton
countyName <- "Fulton"
dataFulton <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataFulton <- rbind(dataFulton, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataFulton <- rbind(dataFulton, pointer)
}
for(i in unique(dataFulton$Period)){
    for(j in 21:39){
        dataDate <- dataFulton$Date[dataFulton$Week == j - 1 & dataFulton$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataFulton <- rbind(dataFulton, pointer)
    }
}

## County: Genesee
countyName <- "Genesee"
dataGenesee <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataGenesee <- rbind(dataGenesee, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataGenesee <- rbind(dataGenesee, pointer)
}
for(i in unique(dataGenesee$Period)){
    for(j in 21:39){
        dataDate <- dataGenesee$Date[dataGenesee$Week == j - 1 & dataGenesee$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataGenesee <- rbind(dataGenesee, pointer)
    }
}

## County: Greene
countyName <- "Greene"
dataGreene <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataGreene <- rbind(dataGreene, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataGreene <- rbind(dataGreene, pointer)
}
for(i in unique(dataGreene$Period)){
    for(j in 21:39){
        dataDate <- dataGreene$Date[dataGreene$Week == j - 1 & dataGreene$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataGreene <- rbind(dataGreene, pointer)
    }
}

## County: Hamilton
countyName <- "Hamilton"
dataHamilton <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataHamilton <- rbind(dataHamilton, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataHamilton <- rbind(dataHamilton, pointer)
}
for(i in unique(dataHamilton$Period)){
    for(j in 21:39){
        dataDate <- dataHamilton$Date[dataHamilton$Week == j - 1 & dataHamilton$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataHamilton <- rbind(dataHamilton, pointer)
    }
}

## County: Herkimer
countyName <- "Herkimer"
dataHerkimer <- trainingData[trainingData$County==countyName,]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataHerkimer <- rbind(dataHerkimer, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataHerkimer <- rbind(dataHerkimer, pointer)
}
for(i in unique(dataHerkimer$Period)){
    for(j in 21:39){
        dataDate <- dataHerkimer$Date[dataHerkimer$Week == j - 1 & dataHerkimer$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataHerkimer <- rbind(dataHerkimer, pointer)
    }
}

## County: Jefferson
countyName <- "Jefferson"
dataJefferson <- trainingData[trainingData$County=="Jefferson",]
dateTest <- as.Date("2014-09-27", format = "%Y-%m-%d")
for(i in 40:53){
    dataDate <- dateTest + ((i - 39) * 7)
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataJefferson <- rbind(dataJefferson, pointer)
}
dateTest <- as.Date("2015-01-03", format = "%Y-%m-%d")
for(i in 1:20){
    dataDate <- dateTest + i * 7
    pointer <- data.frame("2014-2015", countyName, i, dataDate, 0)
    names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
    dataJefferson <- rbind(dataJefferson, pointer)
}
for(i in unique(dataJefferson$Period)){
    for(j in 21:39){
        dataDate <- dataJefferson$Date[dataJefferson$Week == j - 1 & dataJefferson$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataJefferson <- rbind(dataJefferson, pointer)
    }
}

## County: Kings
countyName <- "Kings"
dataKings <- trainingData[trainingData$County==countyName,]
for(i in unique(dataKings$Period)){
    for(j in 21:39){
        dataDate <- dataKings$Date[dataKings$Week == j - 1 & dataKings$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataKings <- rbind(dataKings, pointer)
    }
}

## County: Lewis
countyName <- "Lewis"
dataLewis <- trainingData[trainingData$County==countyName,]
pointer <- data.frame("2014-2015", countyName, 1, as.Date("2015-01-10", format = "%Y-%m-%d"), 0)
names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
dataLewis <- rbind(dataLewis, pointer)
pointer <- data.frame("2014-2015", countyName, 2, as.Date("2015-01-17", format = "%Y-%m-%d"), 0)
names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
dataLewis <- rbind(dataLewis, pointer)
pointer <- data.frame("2014-2015", countyName, 3, as.Date("2015-01-24", format = "%Y-%m-%d"), 0)
names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
dataLewis <- rbind(dataLewis, pointer)
pointer <- data.frame("2014-2015", countyName, 4, as.Date("2015-01-31", format = "%Y-%m-%d"), 0)
names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
dataLewis <- rbind(dataLewis, pointer)
for(i in unique(dataLewis$Period)){
    for(j in 21:39){
        dataDate <- dataLewis$Date[dataLewis$Week == j - 1 & dataLewis$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataLewis <- rbind(dataLewis, pointer)
    }
}

## County: Livingston
countyName <- "Livingston"
dataLivingston <- trainingData[trainingData$County==countyName,]
for(i in unique(dataLivingston$Period)){
    for(j in 21:39){
        dataDate <- dataLivingston$Date[dataLivingston$Week == j - 1 & dataLivingston$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataLivingston <- rbind(dataLivingston, pointer)
    }
}

## County: Madison
countyName <- "Madison"
dataMadison <- trainingData[trainingData$County==countyName,]
for(i in unique(dataMadison$Period)){
    for(j in 21:39){
        dataDate <- dataMadison$Date[dataMadison$Week == j - 1 & dataMadison$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataMadison <- rbind(dataMadison, pointer)
    }
}

## County: Monroe
countyName <- "Monroe"
dataMonroe <- trainingData[trainingData$County==countyName,]
for(i in unique(dataMonroe$Period)){
    for(j in 21:39){
        dataDate <- dataMonroe$Date[dataMonroe$Week == j - 1 & dataMonroe$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataMonroe <- rbind(dataMonroe, pointer)
    }
}

## County: Montgomery
countyName <- "Montgomery"
dataMontgomery <- trainingData[trainingData$County==countyName,]
for(i in unique(dataMontgomery$Period)){
    for(j in 21:39){
        dataDate <- dataMontgomery$Date[dataMontgomery$Week == j - 1 & dataMontgomery$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataMontgomery <- rbind(dataMontgomery, pointer)
    }
}

## County: Nassau
countyName <- "Nassau"
dataNassau <- trainingData[trainingData$County==countyName,]
for(i in unique(dataNassau$Period)){
    for(j in 21:39){
        dataDate <- dataNassau$Date[dataNassau$Week == j - 1 & dataNassau$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataNassau <- rbind(dataNassau, pointer)
    }
}

## County: New york
countyName <- "New york"
dataNewYork <- trainingData[trainingData$County==countyName,]
for(i in unique(dataNewYork$Period)){
    for(j in 21:39){
        dataDate <- dataNewYork$Date[dataNewYork$Week == j - 1 & dataNewYork$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataNewYork <- rbind(dataNewYork, pointer)
    }
}

## County: Niagara
countyName <- "Niagara"
dataNiagara <- trainingData[trainingData$County==countyName,]
for(i in unique(dataNiagara$Period)){
    for(j in 21:39){
        dataDate <- dataNiagara$Date[dataNiagara$Week == j - 1 & dataNiagara$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataNiagara <- rbind(dataNiagara, pointer)
    }
}

## County: Oneida
countyName <- "Oneida"
dataOneida <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOneida$Period)){
    for(j in 21:39){
        dataDate <- dataOneida$Date[dataOneida$Week == j - 1 & dataOneida$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOneida <- rbind(dataOneida, pointer)
    }
}

## County: Onondaga
countyName <- "Onondaga"
dataOnondaga <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOnondaga$Period)){
    for(j in 21:39){
        dataDate <- dataOnondaga$Date[dataOnondaga$Week == j - 1 & dataOnondaga$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOnondaga <- rbind(dataOnondaga, pointer)
    }
}

## County: Ontario
countyName <- "Ontario"
dataOntario <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOntario$Period)){
    for(j in 21:39){
        dataDate <- dataOntario$Date[dataOntario$Week == j - 1 & dataOntario$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOntario <- rbind(dataOntario, pointer)
    }
}

## County: Orange
countyName <- "Orange"
dataOrange <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOrange$Period)){
    for(j in 21:39){
        dataDate <- dataOrange$Date[dataOrange$Week == j - 1 & dataOrange$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOrange <- rbind(dataOrange, pointer)
    }
}

## County: Orleans
countyName <- "Orleans"
dataOrleans <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOrleans$Period)){
    for(j in 21:39){
        dataDate <- dataOrleans$Date[dataOrleans$Week == j - 1 & dataOrleans$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOrleans <- rbind(dataOrleans, pointer)
    }
}

## County: Oswego
countyName <- "Oswego"
dataOswego <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOswego$Period)){
    for(j in 21:39){
        dataDate <- dataOswego$Date[dataOswego$Week == j - 1 & dataOswego$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOswego <- rbind(dataOswego, pointer)
    }
}

## County: Otsego
countyName <- "Otsego"
dataOtsego <- trainingData[trainingData$County==countyName,]
for(i in unique(dataOtsego$Period)){
    for(j in 21:39){
        dataDate <- dataOtsego$Date[dataOtsego$Week == j - 1 & dataOtsego$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataOtsego <- rbind(dataOtsego, pointer)
    }
}

## County: Putnam
countyName <- "Putnam"
dataPutnam <- trainingData[trainingData$County==countyName,]
for(i in unique(dataPutnam$Period)){
    for(j in 21:39){
        dataDate <- dataPutnam$Date[dataPutnam$Week == j - 1 & dataPutnam$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataPutnam <- rbind(dataPutnam, pointer)
    }
}

## County: Queens
countyName <- "Queens"
dataQueens <- trainingData[trainingData$County==countyName,]
for(i in unique(dataQueens$Period)){
    for(j in 21:39){
        dataDate <- dataQueens$Date[dataQueens$Week == j - 1 & dataQueens$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataQueens <- rbind(dataQueens, pointer)
    }
}

## County: Rensselaer
countyName <- "Rensselaer"
dataRensselaer <- trainingData[trainingData$County==countyName,]
for(i in unique(dataRensselaer$Period)){
    for(j in 21:39){
        dataDate <- dataRensselaer$Date[dataRensselaer$Week == j - 1 & dataRensselaer$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataRensselaer <- rbind(dataRensselaer, pointer)
    }
}

## County: Richmond
countyName <- "Richmond"
dataRichmond <- trainingData[trainingData$County==countyName,]
for(i in unique(dataRichmond$Period)){
    for(j in 21:39){
        dataDate <- dataRichmond$Date[dataRichmond$Week == j - 1 & dataRichmond$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataRichmond <- rbind(dataRichmond, pointer)
    }
}

## County: Rockland
countyName <- "Rockland"
dataRockland <- trainingData[trainingData$County==countyName,]
for(i in unique(dataRockland$Period)){
    for(j in 21:39){
        dataDate <- dataRockland$Date[dataRockland$Week == j - 1 & dataRockland$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataRockland <- rbind(dataRockland, pointer)
    }
}

## County: Saratoga
countyName <- "Saratoga"
dataSaratoga <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSaratoga$Period)){
    for(j in 21:39){
        dataDate <- dataSaratoga$Date[dataSaratoga$Week == j - 1 & dataSaratoga$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSaratoga <- rbind(dataSaratoga, pointer)
    }
}

## County: Schenectady
countyName <- "Schenectady"
dataSchenectady <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSchenectady$Period)){
    for(j in 21:39){
        dataDate <- dataSchenectady$Date[dataSchenectady$Week == j - 1 & dataSchenectady$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSchenectady <- rbind(dataSchenectady, pointer)
    }
}

## County: Schoharie
countyName <- "Schoharie"
dataSchoharie <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSchoharie$Period)){
    for(j in 21:39){
        dataDate <- dataSchoharie$Date[dataSchoharie$Week == j - 1 & dataSchoharie$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSchoharie <- rbind(dataSchoharie, pointer)
    }
}

## County: Schuyler
countyName <- "Schuyler"
dataSchuyler <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSchuyler$Period)){
    for(j in 21:39){
        dataDate <- dataSchuyler$Date[dataSchuyler$Week == j - 1 & dataSchuyler$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSchuyler <- rbind(dataSchuyler, pointer)
    }
}

## County: Seneca
countyName <- "Seneca"
dataSeneca <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSeneca$Period)){
    for(j in 21:39){
        dataDate <- dataSeneca$Date[dataSeneca$Week == j - 1 & dataSeneca$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSeneca <- rbind(dataSeneca, pointer)
    }
}

## County: St lawrence
countyName <- "St lawrence"
dataStLawrence <- trainingData[trainingData$County==countyName,]
for(i in unique(dataStLawrence$Period)){
    for(j in 21:39){
        dataDate <- dataStLawrence$Date[dataStLawrence$Week == j - 1 & dataStLawrence$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataStLawrence <- rbind(dataStLawrence, pointer)
    }
}

## County: Steuben
countyName <- "Steuben"
dataSteuben <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSteuben$Period)){
    for(j in 21:39){
        dataDate <- dataSteuben$Date[dataSteuben$Week == j - 1 & dataSteuben$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSteuben <- rbind(dataSteuben, pointer)
    }
}

## County: Suffolk
countyName <- "Suffolk"
dataSuffolk <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSuffolk$Period)){
    for(j in 21:39){
        dataDate <- dataSuffolk$Date[dataSuffolk$Week == j - 1 & dataSuffolk$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSuffolk <- rbind(dataSuffolk, pointer)
    }
}

## County: Sullivan
countyName <- "Sullivan"
dataSullivan <- trainingData[trainingData$County==countyName,]
for(i in unique(dataSullivan$Period)){
    for(j in 21:39){
        dataDate <- dataSullivan$Date[dataSullivan$Week == j - 1 & dataSullivan$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataSullivan <- rbind(dataSullivan, pointer)
    }
}

## County: Tioga
countyName <- "Tioga"
dataTioga <- trainingData[trainingData$County==countyName,]
for(i in unique(dataTioga$Period)){
    for(j in 21:39){
        dataDate <- dataTioga$Date[dataTioga$Week == j - 1 & dataTioga$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataTioga <- rbind(dataTioga, pointer)
    }
}

## County: Tompkins
countyName <- "Tompkins"
dataTompkins <- trainingData[trainingData$County==countyName,]
for(i in unique(dataTompkins$Period)){
    for(j in 21:39){
        dataDate <- dataTompkins$Date[dataTompkins$Week == j - 1 & dataTompkins$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataTompkins <- rbind(dataTompkins, pointer)
    }
}

## County: Ulster
countyName <- "Ulster"
dataUlster <- trainingData[trainingData$County==countyName,]
for(i in unique(dataUlster$Period)){
    for(j in 21:39){
        dataDate <- dataUlster$Date[dataUlster$Week == j - 1 & dataUlster$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataUlster <- rbind(dataUlster, pointer)
    }
}

## County: Warren
countyName <- "Warren"
dataWarren <- trainingData[trainingData$County==countyName,]
for(i in unique(dataWarren$Period)){
    for(j in 21:39){
        dataDate <- dataWarren$Date[dataWarren$Week == j - 1 & dataWarren$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataWarren <- rbind(dataWarren, pointer)
    }
}

## County: Washington
countyName <- "Washington"
dataWashington <- trainingData[trainingData$County==countyName,]
for(i in unique(dataWashington$Period)){
    for(j in 21:39){
        dataDate <- dataWashington$Date[dataWashington$Week == j - 1 & dataWashington$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataWashington <- rbind(dataWashington, pointer)
    }
}

## County: Wayne
countyName <- "Wayne"
dataWayne <- trainingData[trainingData$County==countyName,]
for(i in unique(dataWayne$Period)){
    for(j in 21:39){
        dataDate <- dataWayne$Date[dataWayne$Week == j - 1 & dataWayne$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataWayne <- rbind(dataWayne, pointer)
    }
}

## County: Westchester
countyName <- "Westchester"
dataWestchester <- trainingData[trainingData$County==countyName,]
for(i in unique(dataWestchester$Period)){
    for(j in 21:39){
        dataDate <- dataWestchester$Date[dataWestchester$Week == j - 1 & dataWestchester$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataWestchester <- rbind(dataWestchester, pointer)
    }
}

## County: Wyoming
countyName <- "Wyoming"
dataWyoming <- trainingData[trainingData$County==countyName,]
for(i in unique(dataWyoming$Period)){
    for(j in 21:39){
        dataDate <- dataWyoming$Date[dataWyoming$Week == j - 1 & dataWyoming$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataWyoming <- rbind(dataWyoming, pointer)
    }
}

## County: Yates
countyName <- "Yates"
dataYates <- trainingData[trainingData$County==countyName,]
for(i in unique(dataYates$Period)){
    for(j in 21:39){
        dataDate <- dataYates$Date[dataYates$Week == j - 1 & dataYates$Period == i] + 7
        pointer <- data.frame(i, countyName, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        dataYates <- rbind(dataYates, pointer)
    }
}

trainingDataFull <- rbind(dataAlbany,
                          dataAllegany,
                          dataBronx,
                          dataBroome,
                          dataCattaraugus,
                          dataCayuga,
                          dataChautauqua,
                          dataChemung,
                          dataChenango,
                          dataClinton,
                          dataColumbia,
                          dataCortland,
                          dataDelaware,
                          dataDutchess,
                          dataErie,
                          dataEssex,
                          dataFranklin,
                          dataFulton,
                          dataGenesee,
                          dataGreene,
                          dataHamilton,
                          dataHerkimer,
                          dataJefferson,
                          dataKings,
                          dataLewis,
                          dataLivingston,
                          dataMadison,
                          dataMonroe,
                          dataMontgomery,
                          dataNassau,
                          dataNewYork,
                          dataNiagara,
                          dataOneida,
                          dataOnondaga,
                          dataOntario,
                          dataOrange,
                          dataOrleans,
                          dataOswego,
                          dataOtsego,
                          dataPutnam,
                          dataQueens,
                          dataRensselaer,
                          dataRichmond,
                          dataRockland,
                          dataSaratoga,
                          dataSchenectady,
                          dataSchoharie,
                          dataSchuyler,
                          dataSeneca,
                          dataSteuben,
                          dataStLawrence,
                          dataSuffolk,
                          dataSullivan,
                          dataTioga,
                          dataTompkins,
                          dataUlster,
                          dataWarren,
                          dataWashington,
                          dataWayne,
                          dataWestchester,
                          dataWyoming,
                          dataYates)

# Drop week variable from full training set, order by date
trainingDataFull <- trainingDataFull[-c(3)]
trainingDataFull <- trainingDataFull[order(trainingDataFull$Date),]

## Add dummy weeks to test set
for(i in unique(testingData$County)){
    for(j in 21:39){
        dataDate <- testingData$Date[testingData$Week == j - 1 & testingData$County == i] + 7
        pointer <- data.frame("2018-2019", i, j, dataDate, 0)
        names(pointer) <- c("Period", "County", "Week", "Date", "Incidents")
        testingData <- rbind(testingData, pointer)
    }    
}

arimaTable <- data.frame(County = NA, ARIMA = NA, HW = NA, Time_Period = NA)

outerStartTime <- Sys.time()
for(i in unique(trainingDataFull$County)){
    innerStartTime <- Sys.time()
    
    print(paste("Getting incidents from", i))
    incidents <- trainingDataFull$Incidents[trainingDataFull$County == i]
    
    print(paste("Converting into time-series data"))
    timeSeriesData <- ts(incidents, frequency = 52, start = c(2009, 40))
    print(paste(timeSeriesData))

    print(paste("Training ARIMA model"))
    arimData <- auto.arima(timeSeriesData)
    
    print(paste("Training Holt-Winters model"))
    hwData <- HoltWinters(timeSeriesData, seasonal = "additive")
    
    
    print(paste("Predicting the next 61 periods"))
    fcArima <- forecast(arimData, h = 61)
    fcHW <- forecast(hwData, h = 61)
    
    print(paste("Binding results to values table"))
    for(j in 1:61){
        inputVal <- c(i, fcArima$mean[[j]], fcHW$mean[[j]], j)
        names(inputVal) <- c("County", "ARIMA", "HW", "Time_Period")
        arimaTable <- rbind(arimaTable, inputVal)
    }
    
    innerEndTime <- Sys.time()
    innerTotalTime <- innerEndTime - innerStartTime
    print(paste(i, "processing time:", innerTotalTime)) 
}
outerEndTime <- Sys.time()

outerTotalTime <- outerEndTime - outerStartTime
print(paste("Total processing time:", outerTotalTime)) 

# Remove first row of ARIMA table w/ the NAs
arimaTable <- arimaTable[-1,]
arimaTableTest <- arimaTable


arimaTableTest$Date <- as.Date("2018-09-29", format = "%Y-%m-%d")

for(i in unique(arimaTableTest$County)){
    beginningDate <- as.Date("2018-09-29", format = "%Y-%m-%d")
    for(j in unique(arimaTableTest$Time_Period)){
        arimaTableTest$Date[arimaTableTest$County == i 
                            & arimaTableTest$Time_Period == j] <- as.Date(beginningDate + j * 7, format = "%Y-%m-%d")
        #print(paste(i, ": ", beginningDate + j * 7))
        #print(typeof(j))
    }
}

# Remove weeks designation
arimaTableTest <- arimaTableTest[-c(4)]


#write.csv(arimaTableTest, file = "arimaOutput.csv")


# Round and Absolute Value Predicted amounts
arimaTableTest$ARIMA <- round(abs(as.numeric(arimaTableTest$ARIMA)))
arimaTableTest$HW <- round(abs(as.numeric(arimaTableTest$HW)))
testingData <- testingData[-c(3)]





total <- merge(arimaTableTest, testingData, by=c("Date","County"))
total$Error_ARIMA <- total$ARIMA - total$Incidents
total$Error_HW <- total$HW - total$Incidents

trainingDataFull$ARIMA <- 0
trainingDataFull$Error_ARIMA <- 0
trainingDataFull$HW <- 0
trainingDataFull$Error_HW <- 0

fluDataFinal <- rbind(trainingDataFull, total)
write.csv(fluDataFinal, file = "final.csv")
    


