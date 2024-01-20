#!/usr/bin/env Rscript
#
#
# Script: Verbrauch über das Jahr
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
library(timeDate)
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
stitle <- paste ('Kumulative Produktion ab 21.12. des Vorjahres')

Tag2Rad = function (x, leapyear = 0) {
  
  return ( pi * ( x / (365 + leapyear) - 0.5 ) )
  
}

approximation = function (x, a = 1, b = 1, J = 2023) { 
  
  return ( b * sin(Tag2Rad(x, leap_year(J))) + a )
  
}


SQL = 'select * from HZ50Energie where Prognose = TRUE;'
DT = RunSQL( SQL = SQL )

DT$Jahr = year(as.Date(DT$Datum)+10)
DT$Tag = timeDate::dayOfYear(as.timeDate(as.Date(DT$Datum)+10))
DT$TagRad = Tag2Rad(DT$Tag,leap_year(DT$Jahr))

setDT(DT)[, KumEnergie := cumsum(Energie)/ 1e6, Jahr]

MyColors = c('black',rainbow(6))

for (J in unique(DT$Jahr)) {
DT %>% filter( Jahr == J) %>% ggplot ( ) +
  geom_line( aes( x = Tag, y = KumEnergie
                        , colour = 'Produktion' )
                        , linewidth = 1 
                        , show.legend = TRUE) +
        expand_limits( x = 365 + leap_year(J) ) +
        scale_color_manual( values = MyColors ) +
        scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        labs(  title = paste('Kumulative Solarstrom-Produktion Deutschland', J,  sep = ' ')
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
  
  ra = lm ( data = DT %>% filter( Jahr == J & Tag <= UntilDay ), formula = KumEnergie  ~ sin(TagRad) )
  
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
                 
ggsave(  file = paste( outdir, 'DEU_Solar',J,'.png', sep = '')
               , plot = p
               , bg = "white"
               , width = 1920
               , height = 1080
               , units = "px"
               , dpi = 144 )
}