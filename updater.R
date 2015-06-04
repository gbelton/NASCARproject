# Updates existing database to add new races which took place after the 
# original database was created



#  Load libraries

library(rvest)
library(dplyr)

# Load existing database
load("NASCARdata.RDa")

#  Get List of Races for year
GetRaces <- function(year) {
     url <- paste("http://racing-reference.info/raceyear/", 
                  as.character(year), "/W", sep = "")
     
     races <- html(url) %>%
          html_node(".tb:nth-child(4)") %>%
          html_table()
     races <- filter(races, complete.cases(races))
     names(races)[1] <- "RaceNo"
     races$Date <- as.Date(races$Date, format = "%m/%d/%y")
     return(races)
     
}

# Get drivers for a given race
# NOTE: Driver Rating statistic is not available before 2005
GetDrivers <- function(year, race) {
     url <- paste("http://www.driveraverages.com/nascar_stats/race.php?",
                  "sked_id=",
                  as.character(year),
                  sprintf("%03d", race), sep="")
     drivers <- html(url) %>%
          html_node(".table-large") %>%
          html_table()
     names(drivers)[3] <- "CarNumber"
     drivers <- filter(drivers, Finish != "Finish")
     drivers <- drivers %>% mutate(Finish = as.numeric(Finish),
                                   Start = as.numeric(Start),
                                   Laps = as.numeric(Laps),
                                   Led = as.numeric(Led),
                                   Rating = as.numeric(Rating),
                                   Winnings = as.numeric(
                                        gsub("\\$|,", "", Winnings)))
     return(drivers)
}
buildDatabase <- function(year, race) {
     
     #call function GetRaces to get races for specified year
     #races <- GetRaces(year)
     
     # Get Race Data from races table
     # create vectors of length that will match number of drivers in race
     
     RaceVector <- filter(races, RaceNo == race)
     cars <- as.numeric(RaceVector$Cars)
     RaceNo <- rep(RaceVector$RaceNo, cars)
     Date <- rep(RaceVector$Date, cars)
     Site <- rep(RaceVector$Site, cars)
     Cars <- rep(as.numeric(RaceVector$Cars, cars))
     Len <- rep(RaceVector$Len, cars)
     Sfc <- rep(RaceVector$Sfc, cars)
     Miles <- rep(RaceVector$Miles, cars)
     Cau <- rep(RaceVector$Cau, cars)
     Laps <- rep(RaceVector$Laps,cars)
     Speed <- rep(RaceVector$Speed,cars)
     LC <- rep(RaceVector$LC, cars)
     
     # Get driver data 
     drivers <- GetDrivers(year, race)
     
     # Combine data to build database
     race.data <- mutate(drivers, RaceNo=RaceNo, Date=Date, Site=Site,
                         Cars=Cars, Len=Len, Sfc=Sfc, Miles=Miles, 
                         Cau=Cau, Laps=Laps, Speed=Speed, LC=LC)
     
     return(race.data)
     
     
     
}

CurrentYear <- as.numeric(format(Sys.Date(), "%Y"))
LastRaceDate <- max(NASCAR.data$Date)
LastRaceYear <- as.numeric(format(max(NASCAR.data$Date), "%Y"))
LastRaceNumber <- NASCAR.data$RaceNo[nrow(NASCAR.data)]

for (year in LastRaceYear:CurrentYear){
     
     # Get data for specified year
     
     races <- GetRaces(year)
     
     if (LastRaceNumber==max(races$RaceNo)) {
          stop("No new races to add")
     }
     for (race in (LastRaceNumber+1):max(races$RaceNo)) {
          race.data <- buildDatabase(year,race)
          
          newcolumns <- c("RaceNo", "Date", "Site", "Cars", "Len", "Sfc","Miles", "Cau", 
                          "Speed", "LC", "Driver", "Finish", "Start", "CarNumber", "Make", 
                          "Pts", "Laps", "Led", "Status", "Rating", "Winnings", "Team")
          race.data <- race.data[newcolumns]
          
          NASCAR.data <- rbind(NASCAR.data, race.data)
          remove(race.data)
     }
}

# Save result as .csv file
write.csv(NASCAR.data, file="NASCARdata.csv", row.names=FALSE)

# also save RDa object just to make it easier to reload
save(NASCAR.data, file="NASCARdata.RDa")

