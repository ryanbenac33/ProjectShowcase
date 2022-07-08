# import libraries
library(tidyverse)
library(dplyr)
library(readxl)
library(lubridate)
library(stringr)

# clear workspace and set wd
rm(list=ls())
setwd("D:/Documents/School/DATA 332/Final Project/cabbage_butterfly-main/cabbage_butterfly-main/data")

# import excel sheets as data frames
df_cleanLWA <- read_excel("Cleaned Data LWA.xlsx", sheet=1)
df_complete <- read_excel("CompletePierisData_2022-03-09.xlsx", sheet=1)

# rename core column in clean data
names(df_cleanLWA) <- str_replace_all(names(df_cleanLWA), " ", "")

names(df_cleanLWA)[names(df_cleanLWA) == "coreID"] <- "coreid"
names(df_cleanLWA)[names(df_cleanLWA) == "sex"] <- "SexUpdated"
names(df_cleanLWA)[names(df_cleanLWA) == "LWlength"] <- "LWingLength"
names(df_cleanLWA)[names(df_cleanLWA) == "LWwidth"] <- "LWingWidth"
names(df_cleanLWA)[names(df_cleanLWA) == "LWapexA"] <- "LBlackPatchApex"
names(df_cleanLWA)[names(df_cleanLWA) == "RWlength"] <- "RWingLength"
names(df_cleanLWA)[names(df_cleanLWA) == "RWwidth"] <- "RWingWidth"
names(df_cleanLWA)[names(df_cleanLWA) == "RWapexA"] <- "RBlackPatchApex"

# align naming conventions of columns in case of join
class(df_complete$coreid) = "character"
class(df_complete$SexUpdated) = "character"
class(df_complete$LWingLength) = "double"
class(df_complete$LWingWidth) = "double"
class(df_complete$LBlackPatchApex) = "double"
class(df_complete$RWingLength) = "double"
class(df_complete$RWingWidth) = "double"
class(df_complete$RBlackPatchApex) = "double"

# create working df and remove NA before t-test
df_working <- df_complete %>%
  dplyr::select("coreid", "SexUpdated", "LWingLength", "LWingWidth", "RWingLength", "RWingWidth") %>%
  na.omit(df_working) 

# t-test
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
tsWid <- t.test(lWingWid,rWingWid,paried=TRUE)
probs = c(.9, .95, .99)

# show t-test results
tsLen
tsWid