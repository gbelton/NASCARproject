FinalScores <- read.csv("2015Season.csv", stringsAsFactors = FALSE)
FinalScores$Date <- as.Date(FinalScores$Date, "%m/%d/%Y")

for (race in 1:36) {
        date <- FinalScores$Date[race]
        track <- FinalScores$Track[race]
        
        prediction <- basePredictor(race)
        
        
#Load database
load("~/NASCAR-project/training-data.RData")
NASCARdata <- training.data
remove(training.data)

#Reduce to only necessary variables
keepvars <- c("Date", "Site", "Driver", "Start", "Rating", "Finish")
NASCARdata <- NASCARdata[keepvars]
NASCARdata$Driver <- as.character(NASCARdata$Driver)

NASCARdata <- NASCARdata[which(NASCARdata$Date == date),]

score <- c(150,125,100,80, seq(from = 78, to = 2, by = -2) )



for (row in 1:10) {
        dvr <- prediction$Driver[row]
        fin <- NASCARdata$Finish[which(NASCARdata$Driver==dvr)]
        prediction$ActualFinish[row] <- fin
}

for (row in 1:10) {
        points <- score[prediction$ActualFinish[row]]
        if (prediction$PredictedFinish[row] == prediction$ActualFinish[row]){
                points <- points+25
        }
        prediction$Points[row] <- points
}



RaceScore <- sum(prediction$Points)
FinalScores$Points[race] <- RaceScore


}    
seasonScore <- sum(head(sort(FinalScores$Points,decreasing = TRUE),15))
print(seasonScore)

                
