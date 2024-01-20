#!/usr/bin/env Rscript
#
#
# Script: yield_per_day.r
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
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')

setwd(WD)

source("R/lib/myfunctions.r")
source("R/lib/sql.r")

outdir <- 'png/daily/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

options( 
  digits = 7
  , scipen = 7
  , Outdec = "."
  , max.print = 3000
)

today <- Sys.Date()
heute <- format(today, "%d %b %Y")

citation <- paste( '(cc by 4.0) 2023 by Thomas Arend; Stand:', heute)
stitle <- paste ('Mittelerde Balkonkraftwerk')


  # deye = RunSQL(SQL = paste( 'select * from' 
  #   , '( select date(`time`) as Datum, year(`time`) as Jahr, month(`time`) as Monat, day(`time`) as Tag, max(today_e) as Energy from reports group by Datum'
  #   , ' union select date(`time`) as Datum, year(`time`) as Jahr, month(`time`) as Monat, day(`time`) as Tag, today_e as Energy from daily_yield )'
  #   , ' as R order by Datum ;' ) )
  deye = RunSQL(SQL = paste( 'select date(`time`) as Datum, year(`time`) as Jahr, month(`time`) as Monat, day(`time`) as Tag, max(today_e) as Energy from reports group by Datum ;' ) )
                          
  
  deye$Monate = factor(deye$Monat, levels = 1:12, labels = Monatsnamen )
  
  deye %>% filter (Jahr == 2024 ) %>%
    ggplot (aes ( x = Datum, y = Energy) ) +
    geom_bar( stat='identity', color = 'green', fill = 'green'  ) +
    geom_label ( aes( label = format(round(Energy, digits=2), nsmall = 1) ) , angle = 90) +
     # scale_x_date( ) +
    facet_wrap (vars(Monate), nrow = 2) +
    scale_x_date( date_labels = '%d' ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = paste('Energy production', sep='')
           , subtitle = stitle
           , x ='Date'
           , y ='Yield [kWh]' 
           , caption = citation 
           , colour = 'Legend' ) +
    theme_ipsum() -> p
  
  ggsave(  file = paste( outdir, 'yield_per_day.png', sep = '')
           , plot = p
           , bg = "white"
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )
  