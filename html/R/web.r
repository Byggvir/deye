#!/usr/bin/env Rscript
#
#
# Script: yield.r
#
# Stand: 2023-07-08
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "web.r"

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

#
# Part 1
#

deye = RunSQL(SQL = paste( 'select date(`time`) as Day , min(time(`time`)) as Time, today_e as Energy from reports where date(`time`) >= "2023-07-16" group by Day, Energy;' ) )
  deye$Days <- factor(deye$Day)
  maxDay = max(deye$Day)
  
  deye %>% ggplot ( aes (x = Time, y = Energy )  ) +
    geom_smooth( aes( colour = 'Average' ), level = 0.99, method = 'loess', formula = 'y ~ x' ) +
    geom_line( data = deye %>% filter( Day == maxDay ),  aes (x = Time, y = Energy, colour = Days ), linewidth = 1.5) +
    geom_point( data = deye %>% filter( Day == maxDay ), aes (x = Time, y = Energy, colour = Days ), size = 3 ) +
    scale_x_time( ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = paste('Cumulative Energy Production', sep='')
           , subtitle = stitle
           , x ='Date'
           , y ='Yield [kWh]' 
           , caption = citation ) +
    theme_ipsum() -> p
  
  ggsave(  file = paste( outdir, 'yield.svg', sep = '')
           , device = 'svg'
           , plot = p
           , bg = "white"
           , width = 1920
           , height = 1080
           , units = "px"
           , dpi = 144 )

#
# Part 2
#
  
  
  deye = RunSQL(SQL = paste( 'select date(`time`) as Day, max(today_e) as Energy from reports where date(`time`) > adddate(date(now()), interval -7 day ) group by Day;' ) )

  deye %>% ggplot (aes (x = Day, y = Energy ) ) +
    geom_bar( stat='identity', color = 'green', fill = 'green'  ) +
    geom_label ( aes( label = format(round(Energy, digits=2), nsmall = 1) )) +
    scale_x_date( ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    labs(  title = paste('Energy production', sep='')
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

#
# Part 3
#

  deye = RunSQL(SQL = paste0( 'select *, date(`time`) as Tag from reports;' ) )
  Tage = RunSQL(SQL = paste0( 'select distinct date(`time`) as Tag from reports where date(`time`) = "', format(today,"%F"), '";' ) )  
  for ( TT in Tage$Tag) {
    
    TTT = as.Date(TT, origin = '1970-01-01')
    
    deye %>% filter ( Tag == TT ) %>% ggplot (aes (x = time, y = now_p ) ) +
      geom_bar( stat = 'identity', color = 'green', fill = 'green' ) +
      scale_x_datetime( limits = c(as_datetime(TT*3600*24),as_datetime((TT+1)*3600*24)) ) +
      scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
      expand_limits(y = c(0,800)) +
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
  