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
  SD = (function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ))()
  SD <- unlist(str_split(SD,'/'))
  print(SD)  
}

WD <- paste(SD[1:(length(SD)-1)],collapse='/')

setwd(WD)

source("R/lib/myfunctions.r")
source("R/lib/sql.r")

outdir <- 'png/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

options( 
  digits = 7
  , scipen = 7
  , Outdec = "."
  , max.print = 3000
)

now <- format(Sys.time(), "%Y-%m-%d %H:%M" )

today <- Sys.Date()
heute <- format(today, "%d %b %Y")

citation <- paste( '(cc by 4.0) 2023 by Thomas Arend; Stand:', now)
stitle <- paste ('Mittelerde Balkonkraftwerk')


  deye = RunSQL(SQL = paste( 'select date(`time`) as Day, max(today_e) as Energy from reports group by Day;' ) )
  

  deye %>% ggplot (aes (x = Day, y = Energy ) ) +
    geom_bar( stat='identity', color = 'green', fill = 'green'  ) +
    geom_label ( aes( label = format(round(Energy, digits=2), nsmall = 1) )) +
    scale_x_date( ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = paste('Power production', sep='')
           , subtitle = stitle
           , x ='Date'
           , y ='Yield [kWh]' 
           , caption = citation ) +
    theme_ipsum() -> p
  
  ggsave(  file = paste( outdir, 'yield_per_day.svg', sep = '')
           , plot = p
           , bg = "white"
           , device = 'svg'
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )
  