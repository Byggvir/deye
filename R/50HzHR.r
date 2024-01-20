#!/usr/bin/env Rscript
#
#
# Script: Verbrauch über das Jahr
#
# Stand: 2023-07-08
# (c) 2023 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

# Hochrechnung IST Netzgebiet 50hertz
# Quelle
# https://www.50hertz.com/de/Transparenz/Kennzahlen/ErzeugungEinspeisung/EinspeisungausPhotovoltaik

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(timeDate)
library(ggplot2)
library(ggrepel)
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

outdir <- 'png/50Hz/'
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
title <- 'Kumulierte IST-Werte der Hochrechnung Photovoltaikeinspeisung 50hertz'
subtitle <- paste ('ab 21.12. des Vorjahres')

Tag2Rad = function (x, leapyear = 0) {
  
  return ( pi * ( x / (365 + leapyear) - 0.5 ) )
  
}

approximation = function (x, a = 1, b = 1, J = 2023) { 
  
  return ( b * sin(Tag2Rad(x, leap_year(J))) + a )
  
}


SQL = 'select * from HZ50Energie where Prognose = FALSE;'
DT50Hz = RunSQL( SQL = SQL )

DT50Hz$Jahr = year(as.Date(DT50Hz$Datum)+10)
DT50Hz$Jahre = factor(DT50Hz$Jahr)
DT50Hz$Tag = timeDate::dayOfYear(as.timeDate(as.Date(DT50Hz$Datum)+10))
DT50Hz$TagRad = Tag2Rad(DT50Hz$Tag,leap_year(DT50Hz$Jahr))

setDT(DT50Hz)[, KumEnergie := cumsum(Energie)/ 1000000, Jahr]

MyColors = c('black',rainbow(6))

# for (J in unique(DT50Hz$Jahr)) {
for (J in c(2024)) {
    
  print (J)
  
  DT50Hz %>% filter( Jahr == J  & Prognose == FALSE ) %>% ggplot ( ) +
        geom_line( aes( x = Tag, y = KumEnergie
                        , colour = 'Produktion' )
                        , linewidth = 1 
                        , show.legend = TRUE) +
       # expand_limits( x = 365 + leap_year(J) ) +
        scale_color_manual( values = MyColors ) +
        scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        labs(  title = paste( title, J,  sep = ' ')
               , subtitle = paste( 'Regressionsanalyse von Tag 1 bis n und Extrapolation übers Jahr' )
                                   
               , x ='Tag ab 21.12.'
               , y ='Energie [TWh]'
               , colour = 'Legende'
               , caption = citation ) +
        theme_ipsum() -> p


  CT = data.table (
    Col = c( 'RA bis Tag  1 - 150'
               , 'RA bis Tag 1 - 180'
               , 'RA ganzes Jahr' ) 
    
  )

  i = 1

  RAT = data.table(
    a = rep(0,5)
    , b = rep(0,5)
  )

  i = 1

  for ( UntilDay in c(150, 180, 210, 240, 365) ) {
    
    ra = lm ( data = DT50Hz %>% filter( Jahr == J & Tag <= UntilDay & Prognose == FALSE ), formula = KumEnergie  ~ sin(TagRad) )
    
    ab = ra$coefficients
    print(ab)
    
    RAT[i,1] = ab[1]
    RAT[i,2] = ab[2]
    
    i = i + 1
    
  }
  
  p + 
    geom_function( fun = approximation
                     , args = list ( a = RAT$a[1], RAT$a[1], J = J )
                     , aes( colour = 'RA bis Tag 150' )
                     , linetype = 'dotted'
                     , linewidth = 1
                     , alpha = 0.8 
                     , show.legend = TRUE ) +
    geom_function( fun = approximation
                   , args = list ( a = RAT$a[2], RAT$a[2], J = J )
                   , aes( colour = 'RA bis Tag 180' )
                   , linetype = 'dotted'
                   , linewidth = 1
                   , alpha = 0.8 
                   , show.legend = TRUE) +
    geom_function( fun = approximation
                   , args = list ( a = RAT$a[3], RAT$a[3], J = J )
                   , aes( colour = 'RA bis Tag 210' )
                   , linetype = 'dotted'
                   , linewidth = 1
                   , alpha = 0.8 
                   , show.legend = TRUE ) +
    geom_function( fun = approximation
                   , args = list ( a = RAT$a[4], RAT$a[4], J = J )
                   , aes( colour = 'RA bis Tag 240' )
                   , linetype = 'dotted'
                   , linewidth = 1
                   , alpha = 0.8 
                   , show.legend = TRUE) +
    geom_function( fun = approximation
                   , args = list ( a = RAT$a[5], RAT$a[5], J = J )
                   , aes( colour = 'RA ganzes Jahr' )
                   , linetype = 'dotted'
                   , linewidth = 1
                   , alpha = 0.8 
                   , show.legend = TRUE) -> p
                   
  ggsave(  file = paste( outdir, '50Hz_Solar_',J,'.png', sep = '')
                 , plot = p
                 , bg = "white"
                 , width = 1920
                 , height = 1080
                 , units = "px"
                 , dpi = 144 )
  
}

MaxE = DT50Hz %>% group_by(Jahr) %>% summarise(MaxEnergie = max(KumEnergie))
MaxE$Jahre = factor(MaxE$Jahr)

DT50Hz %>% filter( Jahr < 2024 ) %>% ggplot ( ) +
  geom_line( aes( x = Tag, y = KumEnergie
                  , colour = Jahre )
             , linewidth = 1 
             , show.legend = TRUE) +
  geom_line( aes( x = Tag, y = KumEnergie
                  , colour = Jahre )
             , linewidth = 1 
             , show.legend = TRUE ) +
  geom_label_repel(data = MaxE %>%  filter( Jahr < 2024 )
             , aes(x = 366, y = MaxEnergie, label = paste0(round( MaxEnergie, 1), ' (', Jahr, ')' ), colour = Jahre )
             , show.legend = FALSE ) +
  # expand_limits( x = 366 ) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  labs(  title = paste( title, sep = ' ')
         , subtitle = paste( subtitle, 'Hochrechnung IST' )
         
         , x ='Tag ab 21.12.'
         , y ='Energie [TWh]'
         , colour = 'Legende'
         , caption = citation ) +
  theme_ipsum() -> p


ggsave(  file = paste( outdir, '50Hz_Solar.png', sep = '')
         , plot = p
         , bg = "white"
         , width = 1920
         , height = 1080
         , units = "px"
         , dpi = 144 )

