#  Scrapes data from websites to build database

#  Load libraries

library(rvest)
library(dplyr)

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


# Putting it all together

# Check to see if database already exists; if not, create it

if (!exists("NASCAR.data")) {
        NASCAR.data <- data.frame(Finish=numeric(),   
                                  Start=numeric(),
                                  CarNumber=character(),
                                  Driver=character(),
                                  Make=character(),
                                  Pts=character(),
                                  Laps=numeric(),
                                  Led=numeric(),
                                  Status = character(),
                                  Rating = numeric(),
                                  Winnings = numeric(),
                                  Team = character(),
                                  RaceNo = numeric(),
                                  Date = as.Date(character()),
                                  Site = character(),
                                  Cars = numeric(),
                                  Len = numeric(),
                                  Sfc = character(),
                                  Miles = numeric(),
                                  Cau = numeric(),
                                  Speed = numeric(), 
                                  LC = numeric(),
                                  stringsAsFactors=FALSE)
}
# NOTE: Driver Rating statistic is not available before 2005
for (year in 2005:2015){

     # Get data for specified year

     races <- GetRaces(year)


     for (race in 1:max(races$RaceNo)) {
          race.data <- buildDatabase(year,race)
          NASCAR.data <- rbind(NASCAR.data, race.data)
          remove(race.data)
          }
}

# Reorder columns in data frame to put race data in front

newcolumns <- c("RaceNo", "Date", "Site", "Cars", "Len", "Sfc","Miles", "Cau", 
                "Speed", "LC", "Driver", "Finish", "Start", "CarNumber", "Make", 
                "Pts", "Laps", "Led", "Status", "Rating", "Winnings", "Team")
NASCAR.data <- NASCAR.data[newcolumns]

# Save result as .csv file
write.csv(NASCAR.data, file="NASCARdata.csv", row.names=FALSE)
