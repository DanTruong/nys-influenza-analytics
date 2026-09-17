# Load requisite libraries
library(dplyr)
library(plyr)
library(tidyr)

# Load in dataset file
fluDataFinal <- read.csv("data/fluDataFinal.csv")

# Drop X var
fluDataFinal <- fluDataFinal[-c(1)]

# Fix Date var
fluDataFinal$Date <- as.Date(fluDataFinal$Date, format = "%Y-%m-%d")
fluDataFinal <- fluDataFinal[order(fluDataFinal$Date),]
    
dataTest <- fluDataFinal[fluDataFinal$Period=="2018-2019" | fluDataFinal$Period=="2019-2020", ]
dataTest$Error_ARIMA_SQ <- dataTest$Error_ARIMA ^ 2
dataTest$Error_HW_SQ <- dataTest$Error_HW ^ 2

mseTable <- data.frame(County = NA, MSE_ARIMA = NA, MSE_HW = NA)
for(i in unique(dataTest$County)){
    input <- data.frame(i, 
                        round(mean(dataTest$Error_ARIMA_SQ[dataTest$County == i]), digits = 2), 
                        round(mean(dataTest$Error_HW_SQ[dataTest$County == i]), digits = 2))
    names(input) <- c("County", "MSE_ARIMA", "MSE_HW")
    mseTable <- rbind(mseTable, input)
}
mseTable <- mseTable[-1,]

# Aggregation example
#fluRange <- fluDataFinal[fluDataFinal$Date >= as.Date("2017-10-31", format = "%Y-%m-%d") &
#                             fluDataFinal$Date <= as.Date("2020-06-30", format = "%Y-%m-%d"), ]
#fluRangeSum <- aggregate(. ~ County + Latitude + Longitude, 
#                         fluDataFinal[
#                                fluDataFinal$Date >= as.Date("2017-10-31", format = "%Y-%m-%d") &
#                                fluDataFinal$Date <= as.Date("2020-06-30", format = "%Y-%m-%d"),   
#                         ], 
#                         sum)
