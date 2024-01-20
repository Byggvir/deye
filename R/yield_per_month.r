#!/usr/bin/env Rscript
#
#
# Script: yield_per_week.r
#
# Stand: 2023-07-08
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#
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

outdir <- 'png/weekly/'
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


Yield = RunSQL( SQL = 'select * from energy_per_month;' ) 
Yield$Datum = as.Date( paste0( Yield$Jahr, '-', Yield$Monat , '-01' ))

max_Energy = max(Yield$Energy)

  Yield %>% ggplot (aes ( x = Datum , y = Energy ) ) +
    geom_bar( stat = 'identity', color = 'green', fill = 'green' ) +
    geom_label( aes ( y = 0, label = paste (Energy, '\n', round(Energy / max_Energy * 100,1) , ' %', sep = '') ), size = 3 ) +
    # scale_x_discrete( ) +
    scale_x_date( breaks = '1 month',  date_labels = '%Y-%m') +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = paste('Energie pro Monat', sep='')
           , subtitle =  stitle
           , x = 'Monat'
           , y = 'Energie [kWh]' 
           , colour = 'Legende'
           , fill = 'Fill'
           , caption = citation
           , colour = 'Legend'  ) +
    theme_ipsum() + 
    theme( axis.text.x = element_text( vjust = 0.5, angle = 90 ) ) -> p
  
  ggsave(  file = paste( outdir, 'yield_per_month.png', sep = '')
           , plot = p
           , bg = "white"
           , device = 'png'
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )
