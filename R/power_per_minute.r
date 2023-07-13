#!/usr/bin/env Rscript
#
#
# Script: deye.r
#
# Stand: 2023-07-08
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "deye.r"

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


  deye = RunSQL(SQL = paste( 'select *, date(`time`) as Tag from reports where `time` > "2023-07-09 00:00:00";' ) )
  Tage = RunSQL(SQL = 'select distinct date(`time`) as Tag from reports where `time` > "2023-07-09 00:00:00";')
  
  for ( TT in Tage$Tag) {
  
    TTT = as.Date(TT, origin = '1970-01-01')
    
  deye %>% filter ( Tag == TT ) %>% ggplot (aes (x = time, y = now_p ) ) +
    geom_bar( stat = 'identity', color = 'green', fill = 'green' ) +
    scale_x_datetime( ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    expand_limits(y = c(0,400)) +
    labs(  title = paste('Power production', sep='')
           , subtitle =  TTT
           , x ='Date / Time'
           , y ='Electrical power [Watt]' 
           , colour = 'Lines'
           , fill = 'Fill'
           , caption = citation ) +
    theme_ipsum() -> p
  
  ggsave(  file = paste( outdir, 'power_', TTT, '.svg', sep = '')
           , plot = p
           , bg = "white"
           , device = 'svg'
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )
  }
  
  ggsave(  file = paste( outdir, 'power.svg', sep = '')
           , plot = p
           , bg = "white"
           , device = 'svg'
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )