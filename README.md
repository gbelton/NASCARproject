# NASCAR Project

This is an attempt to apply statistical machine learning to predict the outcome
of NASCAR Sprint Cup Races.  

Currently we have the file _createNASCARdatabase.R_ which scrapes two websites
and combines the data to create a database of NASCAR race results, which it 
then outputs as _NASCARdata.csv_.

There is also a _NASCARdata.RDa_ file which can be read directly into R using 
the command **load(NASCARdata.RDa)**.

Next step is to write an R script to update the existing data frame as new races 
become available. 

