#### Apply machine-learning model to predict outcome of NASCAR race

#####IMPORTANT: Before running this script, you must have the following variables in
#####the environment:
#####track = name of track at which race to be predicted will be held
#####date = date of race to be predicted in YYYY-MM-DD format

predictNASCAR <- function(date="2016-02-21", track="Daytona"){
#Load needed libraries
library(dplyr)
library(caret)
library(gbm)

#Load database
load("~/NASCAR-project/training-data.RData")
NASCARdata <- training.data
remove(training.data)

#Reduce to only necessary variables
keepvars <- c("Date", "Site", "Driver", "Start", "Rating", "Finish")
NASCARdata <- NASCARdata[keepvars]

#Get Track Data
tracks <- read.csv("NASCARTracks.csv")
NASCARdata = join(NASCARdata,tracks,by='Site')

#Build a prediction database. Takes the name of a track and date of race as input, and returns 
#a data.frame of drivers and prediction variables
###Needs variables date and track set in environment before sourcing

        drivers <- NASCARdata[,"Driver"]
        drivers <- unique(drivers)
        drivers <- as.character(drivers)
        drivers <- as.data.frame(drivers)
        colnames(drivers) = "Driver"
        
        #remove races that occur on or after prediction date 
        #NASCARdata <- NASCARdata[which(NASCARdata$Date<date), ]
        NASCARdata$Site <- as.character(NASCARdata$Site)
        NASCARdata$Driver <- as.character(NASCARdata$Driver)
        
        #calculate career average for each driver
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr), ]
                drivers$CareerAvg[row] <- mean(temp$Finish)
                
        }
        
        #calculate average of last 10 races for each driver
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr), ]
                drivers$Avg10[row] <- mean(tail(temp$Finish),10)
                
        }
        #calculate average of last 5 races for each driver
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr), ]
                drivers$Avg5[row] <- mean(tail(temp$Finish),5)
                
        }
        
        #Calculate average finish at same track
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr &
                                            NASCARdata$Site==track), ]
                drivers$TrackAvg[row] <- mean(temp$Finish)
                
        }
        
        #Calcuate average for same track type
        NSC <- tracks[(which(tracks$Site==track)), 2]
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr &
                                                  NASCARdata$NASCAR==NSC), ]
                drivers$NTypeAvg[row] <- mean(temp$Finish)
                
        }

        #Calcuate average for same track type
        ACC <- tracks[(which(tracks$Site==track)), 3]
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr &
                                                  NASCARdata$AccuPredict==ACC), ]
                drivers$AccuPredictAvg[row] <- mean(temp$Finish)
                
        }
        
        #calculate average Rating of last 10 races for each driver
        for (row in 1:nrow(drivers)) {
                dvr <- drivers$Driver[row]
                temp <- NASCARdata[ which(NASCARdata$Driver==dvr), ]
                drivers$RtgAvg10[row] <- mean(tail(temp$Rating),10)
                
        }
        
        #Clean data
        drivers <- drivers[complete.cases(drivers),]
        
        
                #run prediction function
        load("modelFit.RData")
        drivers$prediction <- predict(modelFit, drivers)
        drivers <- drivers[order(drivers$prediction), ]
        
        for (row in 1:nrow(drivers)) {
                drivers$PredictedFinish[row] <- row
        }
        
prediction <- head(drivers[,c("PredictedFinish", "Driver")],20)

return(prediction)
        
}

