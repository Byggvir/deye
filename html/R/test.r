#!/usr/bin/env Rscript
#
#
# Script: deye.r
#
# Stand: 2023-07-08
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "yield_per_day.r"

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

# Daten

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When executed in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
 
} else {
  
  #  When executing on command line 
  SD = (function() return( 
    if( length(sys.parents() ) == 1 ) getwd() else dirname(sys.frame(1)$ofile) 
    ) ) ()
  SD <- unlist(str_split(SD,'/'))
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')

setwd(WD)

cat("\nWD=", WD, '\n\n', sep='')

source("R/lib/myfunctions.r")
source("R/lib/sql.r")
