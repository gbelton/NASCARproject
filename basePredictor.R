#### Apply machine-learning model to predict outcome of NASCAR race

#####IMPORTANT: Before running this script, you must have the following variables in
#####the environment:
#####track = name of track at which race to be predicted will be held
#####date = date of race to be predicted in YYYY-MM-DD format

basePredictor <- function(race = 1){
#Load needed libraries
library(dplyr)
library(caret)
library(gbm)

#Load database
NASCARdata <- read.csv("PointStandings2015.csv")

col <- race + 1
drivers <- NASCARdata[order(-NASCARdata[,col]), ]


for (row in 1:nrow(drivers)) {
        drivers$PredictedFinish[row] <- row
}

prediction <- head(drivers[,c("PredictedFinish", "Driver")],10)
prediction$Driver <- as.character(prediction$Driver)

return(prediction)
        
}

