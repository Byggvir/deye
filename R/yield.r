#!/usr/bin/env Rscript
#
#
# Script: yield.r
#
# Stand: 2023-07-08
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "yield.r"

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

outdir <- 'png/'
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

deye = RunSQL(SQL = paste( 'select date(`time`) as Day , min(time(`time`)) as Time, today_e as Energy from reports where date(`time`) >= "2023-07-16" group by Day, Energy;' ) )
  deye$Days <- factor(deye$Day)
  maxDay = max(deye$Day)
  
  deye %>% ggplot ( aes ( x = Time, y = Energy )  ) +
    geom_smooth( aes( colour = 'Average' ), level = 0.99 ) +
    geom_line( data = deye %>% filter( Day == maxDay ),  aes (x = Time, y = Energy, colour = Days ), linewidth = 1.5) +
    geom_point( data = deye %>% filter( Day == maxDay ), aes (x = Time, y = Energy, colour = Days ), size = 3 ) +
    scale_x_time( ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = paste('Energy production', sep='')
           , subtitle = stitle
           , x ='Date'
           , y ='Yield [kWh]' 
           , caption = citation ) +
    theme_ipsum() -> p
  
  ggsave(  file = paste( outdir, 'yield.png', sep = '')
           , plot = p
           , bg = "white"
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )
  