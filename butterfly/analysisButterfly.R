# import libraries
library(tidyverse)
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)
library(Hmisc)

# clear workspace and set wd
rm(list=ls())
setwd("C:/Users/benac/Documents/GitHub/data332/butterfly/Original Data")

# import excel sheets as data frames
df_cleanLWA <- read_excel("Cleaned Data LWA  - ORIGINAL.xlsx", sheet=1)
df_complete <- read_excel("CompletePierisData_2022-03-09 - ORIGINAL.xlsx", sheet=2)

# rename column in clean data in case of join
names(df_cleanLWA) <- str_replace_all(names(df_cleanLWA), " ", "")

names(df_cleanLWA)[names(df_cleanLWA) == "coreID"] <- "coreid"
names(df_cleanLWA)[names(df_cleanLWA) == "sex"] <- "SexUpdated"
names(df_cleanLWA)[names(df_cleanLWA) == "LWlength"] <- "LWingLength"
names(df_cleanLWA)[names(df_cleanLWA) == "LWwidth"] <- "LWingWidth"
names(df_cleanLWA)[names(df_cleanLWA) == "LWapexA"] <- "LBlackPatchApex"
names(df_cleanLWA)[names(df_cleanLWA) == "RWlength"] <- "RWingLength"
names(df_cleanLWA)[names(df_cleanLWA) == "RWwidth"] <- "RWingWidth"
names(df_cleanLWA)[names(df_cleanLWA) == "RWapexA"] <- "RBlackPatchApex"


### data cleaning ###
# clean only the complete dataset
# make sure SexUpdated is all male or female
unique(df_complete$SexUpdated)

df_complete$SexUpdated[df_complete$SexUpdated == "M"] <- "male"
df_complete$SexUpdated[df_complete$SexUpdated == "F?"] <- "female"
df_complete$SexUpdated[df_complete$SexUpdated == "F"] <- "female"
df_complete$SexUpdated[df_complete$SexUpdated == "Female"] <- "female"
df_complete$SexUpdated[df_complete$SexUpdated == "Male"] <- "male"
df_complete$SexUpdated[df_complete$SexUpdated == "male?"] <- "male"
unique(df_complete$SexUpdated)

# make sure years are ready
unique(df_complete$YearUpdated)


### understanding the analysis features in this dataset
descript <- describe(df_complete)
descript

# change column data type to double
class(df_complete$LWingLength) = "double"
class(df_complete$LWingWidth) = "double"
class(df_complete$RWingLength) = "double"
class(df_complete$RWingWidth) = "double"

# create working df
df_working <- df_complete %>%
  dplyr::select("coreid", "YearUpdated","SexUpdated", "LWingLength", "LWingWidth", "RWingLength", "RWingWidth") %>%
  na.omit(df_complete) 

# create wingspan column
df_working$wingspan <- df_working$LWingWidth + df_working$RWingWidth

## get stats of proportions
# left wing length
lWingLenMin <- min(df_working$LWingLength)
lWingLenMax <- max(df_working$LWingLength)
lWingLenAvg<- mean(df_working$LWingLength)
# right wing length
rWingLenMin <- min(df_working$RWingLength)
rWingLenMax <- max(df_working$RWingLength)
rWingLenAvg<- mean(df_working$RWingLength)

# left wing width
lWingWidMin <- min(df_working$LWingWidth)
lWingWidMax <- max(df_working$LWingWidth)
lWingWidAvg<- mean(df_working$LWingWidth)
# right wing width
rWingWidMin <- min(df_working$RWingWidth)
rWingWidMax <- max(df_working$RWingWidth)
rWingWidAvg<- mean(df_working$RWingWidth)

## put all info in a table for easy viewing
df_wingStats <- data.frame(c(lWingLenMin, lWingLenAvg, lWingLenMax), c(lWingWidMin, lWingWidAvg, lWingWidMax), c(rWingLenMin, rWingLenAvg, rWingLenMax), c(rWingWidMin, rWingWidAvg, rWingWidMax))
rownames(df_wingStats) <- c('Min', 'Average', 'Max')
colnames(df_wingStats) <- c('Left Length', 'Left Width', 'Right Length', 'Right Width')
df_wingStats


### visualizations ###
# this analysis focuses only on wing proportions including wing length, width, and apex spot
## histogram for wingspan
wingspan <- df_working$wingspan
hist(wingspan)

## count over time
# get df of average wingspan groupby year
year_group <- df_working %>%
  group_by(YearUpdated) %>%
  summarise(AverageWing = mean(wingspan))

# filter out year 200
year_group <- filter(year_group, YearUpdated != 200)
plot(year_group$YearUpdated,year_group$AverageWing,type = "l",col = "red", xlab = "Year", ylab = "Average", 
     main = "Wingspan Over Time")

## count over time by gender
# get dfs by sex of average wingspan, year, and gender
# male
male <- filter(df_working, SexUpdated != 'female')

year_group_male <- male %>%
  group_by(YearUpdated) %>%
  summarise(AverageWing = mean(wingspan), .groups = 'drop')
year_group_male <- filter(year_group_male, YearUpdated != 200)
plot(year_group_male$YearUpdated,year_group_male$AverageWing,type = "l",col = "blue", xlab = "Year", ylab = "Average", 
     main = "Wingspan Over Time")

# female
female <- filter(df_working, SexUpdated != 'male')
year_group_female <- female %>%
  group_by(YearUpdated) %>%
  summarise(AverageWing = mean(wingspan), .groups = 'drop')
year_group_female <- filter(year_group_female, YearUpdated != 200)
lines(year_group_female$YearUpdated,year_group_female$AverageWing,type = "l",col = "red", xlab = "Year", ylab = "Average", 
     main = "Wingspan Over Time")

## box plot of width by gender
boxplot(LWingWidth~SexUpdated,data=df_working, main="Left Wing Width by Gender",
        xlab="Gender", ylab="Wing Width")
boxplot(RWingWidth~SexUpdated,data=df_working, main="Right Wing Width by Gender",
        xlab="Gender", ylab="Wing Width")


### t-test ###
# choose columns, we will do 2 separate t tests; one for length and one for width
lWingLen <- df_working$RWingLength
rWingLen <- df_working$RWingWidth
lWingWid <- df_working$LWingLength
rWingWid <- df_working$LWingWidth

# normalize rnorm(n=sample size, mean, std)
lWingLen <- rnorm(length(lWingLen), mean(lWingLen), sd(lWingLen))
rWingLen <- rnorm(length(rWingLen), mean(rWingLen), sd(rWingLen))
lWingWid <- rnorm(length(lWingWid), mean(lWingWid), sd(lWingWid))
rWingWid <- rnorm(length(rWingWid), mean(rWingWid), sd(rWingWid))

# t test on length
tsLen <- t.test(lWingLen,rWingLen,paired=TRUE)
# t test on width
tsWid <- t.test(lWingWid,rWingWid,paried=TRUE)
probs = c(.9, .95, .99)

# show t-test results
tsLen
tsWid

