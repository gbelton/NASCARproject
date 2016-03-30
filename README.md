# NASCAR Project

This is an attempt to apply statistical machine learning to predict the outcome
of NASCAR Sprint Cup Races.  

Currently we have the file _createNASCARdatabase.R_ which scrapes two websites
and combines the data to create a database of NASCAR race results, which it 
then outputs as _NASCARdata.csv_.

There is also a _NASCARdata.RDa_ file which can be read directly into R using 
the command **load(NASCARdata.RDa)**.

The file _updater.R_ checks for new races and adds them to the database.

There is a codebook which describes the variables in the database. It is available 
in three different formats: Markdown, pdf, and html. (It probably needs to be 
updated!)

_modelFit.RData_ contains the model which was created by the program in 
_machineLearning.RMD_. The program _racePredictor.R_ uses _modelFit.RData_ to 
predict the outcome of the next race. 

