## Construct the data set for the presentation
library(dplyr)

## Extract original data
sourceRecords <- "repdata_data_StormData.csv.bz2"
sourceUrl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
if (!file.exists(sourceRecords)) {
   download.file(sourceUrl,sourceRecords)
}

# Extract files from the zip and read the data
rawData <- read.table(sourceRecords, sep = ",", header = TRUE)

## Select useful columns
dataSelected <- select(rawData, EVTYPE, FATALITIES, INJURIES, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP, LATITUDE, LONGITUDE)
head(dataSelected)



## Data formatting
dataFormatted <- dataSelected
# Fatalities and injured persons are added to produce the attribute *HARMED*
dataFormatted$HARMED <- dataFormatted$FATALITIES + dataFormatted$INJURIES

# Crop's damages are converted to their scale then copied to produce the attribute *DAMAGES*
dataFormatted <- dataFormatted %>%
   mutate(
      DAMAGES = case_when(
         CROPDMGEXP == ""  ~ 0,
         CROPDMGEXP == "?" ~ 0,       # Equivalent of NA
         CROPDMGEXP == "0" ~ CROPDMG, # Considers as unit $
         CROPDMGEXP == "2" ~ 0,       # A zero is associated in data set
         CROPDMGEXP == "B" ~ (CROPDMG*1000000000),
         CROPDMGEXP == "k" | CROPDMGEXP == "K" ~ (CROPDMG*1000),
         CROPDMGEXP == "m" | CROPDMGEXP == "M" ~ (CROPDMG*1000000)
      )
   )

# Properties' damages are converted to their scale then added to the attribute *DAMAGES*
dataFormatted <- dataFormatted %>%
   mutate(
      DAMAGES = DAMAGES + case_when(
         PROPDMGEXP == ""  ~ 0,
         PROPDMGEXP %in% c("?","-","+","0","1","2","3","4","5","6","7","8","h","H") ~ PROPDMG, # Considered as $
         PROPDMGEXP == "B" ~ (PROPDMG*1000000000),
         PROPDMGEXP == "k" | PROPDMGEXP == "K" ~ (PROPDMG*1000),
         PROPDMGEXP == "m" | PROPDMGEXP == "M" ~ (PROPDMG*1000000)
      )
   )

# Remove now unuseful attributes
dataFormatted <- dataFormatted %>%
   select(EVTYPE, LATITUDE, LONGITUDE, HARMED, DAMAGES)

# Aggregate harmed persons and damages in a single value
dataFormatted$Harm.Dam. <- 1000000 * dataFormatted$HARMED + dataFormatted$DAMAGES

# Latitude and Longitude must be formatted
dataFormatted$LATITUDE  <- paste(     substr(dataFormatted$LATITUDE,  1, 2), ".", substr(dataFormatted$LATITUDE,  3, 4), sep = "")
dataFormatted$LONGITUDE <- ifelse(nchar(dataFormatted$LONGITUDE)==4, 
                                  paste("-", substr(dataFormatted$LONGITUDE, 1, 2), ".", substr(dataFormatted$LONGITUDE, 3, 4), sep = ""), 
                                  paste("-", substr(dataFormatted$LONGITUDE, 1, 3), ".", substr(dataFormatted$LONGITUDE, 4, 5), sep = "")
)
dataFormatted$LATITUDE  <- as.numeric(dataFormatted$LATITUDE)
dataFormatted$LONGITUDE <- as.numeric(dataFormatted$LONGITUDE)
dataFormatted <- subset(dataFormatted, is.na(dataFormatted$LONGITUDE)==FALSE & dataFormatted$LONGITUDE!=0)
   
## Select only the 3 most harmful and the 3 most damaging

# Order data set by decreasing harm
dataOrdered <- dataFormatted
dataOrdered <- dataOrdered %>%
   group_by(EVTYPE) %>%
   summarise(HARMED = sum(HARMED)) %>%
   arrange(desc(HARMED))
harmfulTypes <- data.frame(dataOrdered[1:3,1])

# Order data set by decreasing damages
dataOrdered <- dataFormatted
dataOrdered <- dataOrdered %>%
   group_by(EVTYPE) %>%
   summarise(DAMAGES = sum(DAMAGES)) %>%
   arrange(desc(DAMAGES))
damagingTypes <- data.frame(dataOrdered[1:3,1])

# Create a subset of the data set for these values
dataFormatted <- dataFormatted %>%
   filter(EVTYPE %in% harmfulTypes$EVTYPE | EVTYPE %in% damagingTypes$EVTYPE)

## Write table on a file
write.table(dataFormatted, "Events_Data_Set.txt")
