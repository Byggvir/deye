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

outdir <- 'png/RA/'
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
title <- paste ('Solarenergie-Produktion Balkonkraftwerk Mittelerde')
subtitle <- paste ('Kumulative Produktion ab 21.12. des Vorjahres')

Tag2Rad = function (x, leapyear = 0) {
  
  return ( pi * ( x / (365 + leapyear) - 0.5 ) )
  
}

approximation = function (x, a = 1, b = 1, J = 2023) { 
  
  return ( b * sin(Tag2Rad(x, leap_year(J))) + a )
  
}

SQL = paste( 'select * from Production;' )

SolarEnergie = RunSQL( SQL = SQL )
SolarEnergie$TagRad = Tag2Rad(SolarEnergie$Tag,leap_year(SolarEnergie$Jahr))

CT = data.table(
  J = c()
  , a = c()
  , b = c()
)

  for (J in unique(SolarEnergie$Jahr)) {
    
    dt = SolarEnergie %>% filter ( Jahr == J )
    
    if ( nrow(dt) > 1 ) { 
      ra = lm ( data = dt, formula = Energy  ~ sin(TagRad) )
      
      R2 = summary(ra)$r.squared
      cat( R2 , '\n' )
      
      ab = ra$coefficients
      CT = rbind( CT, list( J = J
                            , a = ab[1]
                            , b = ab[2])
                )

      maxResiduals = max(abs(ra$residuals))
      
      ci = confint(ra)
      print(ab)
      print(ci)
      
      LABELS = as.Date(paste0(J,'-',1:12,'-01'))
      BREAKS = dayOfYear(as.timeDate(LABELS)) + 10
      
      dt %>% ggplot ( ) +
        geom_function( fun = approximation
                       , args = list ( a = ci[1,1], b = ci[2,1], J = J)
                       , aes( colour = 'RA lower' )
                       , linetype = 'dotted'
                       , linewidth = 0.5
                       , alpha = 0.8) +
        geom_function( fun = approximation
                       , args = list ( a = ci[1,2], b = ci[2,2], J = J)
                       , aes( colour = 'RA upper' )
                       , linetype = 'dotted'
                       , linewidth = 0.5
                       , alpha = 0.8) +
        geom_function( fun = approximation
                       , args = list ( a = ab[1], b = ab[2], J = J)
                       , aes( colour = 'RA mean' )
                       , linetype = 'dotted'
                       , linewidth = 1
                       , alpha = 0.8) +
        geom_line( aes( x = Tag, y = Energy 
                        , colour = 'Produktion' )
                        , linewidth = 1 ) +
        #expand_limits( x =  365 + leap_year(J) ) +
        scale_colour_manual( values = c( 'blue', 'green', 'black' , 'red')) +
        scale_x_continuous( breaks = BREAKS, labels = LABELS ) +
        scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
        labs(  title = paste(title, J,  sep = ' ')
               , subtitle = paste( 'Energy(Tag) =' ,round(ab[2],2)
                                   , '* sin( pi * ( Tag /'
                                   , 365 + leap_year(J)
                                   , '- 0.5 ) ) +',  round(ab[1],2) )
               , x ='Tag ab 21.12.'
               , y ='Energie [kWh]'
               , colour = 'Legende'
               , caption = citation ) +
        theme_ipsum() +
        theme ( axis.text.x = element_text( angle = 90 ) ) -> p
      
      ggsave(  file = paste( outdir, 'RA-Solar_', J, '.png', sep = '')
               , plot = p
               , bg = "white"
               , width = 1920
               , height = 1080
               , units = "px"
               , dpi = 144 )

      }
    
  }


dt %>% ggplot ( ) +
  geom_function( fun = approximation
                 , args = list ( a = CT$b[1], b = CT$b[1], J = J)
                 , aes( colour = 'Erwartet' )
                 , linetype = 'dotted'
                 , linewidth = 1
                 , alpha = 0.8) +
  geom_line( aes( x = Tag, y = Energy 
                  , colour = 'Produktion' )
             , linewidth = 1 ) +
  expand_limits( x = ( max(dt$Tag) %/% 10  + 2) *10 ) + # 365 + leap_year(J) ) +
  scale_colour_manual( values = c( 'blue', 'green', 'black' , 'red')) +
  scale_x_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  labs(  title = paste( title, J,  sep = ' ')
         , subtitle = paste( 'Energie(Tag) = ' ,round(CT$b[1],2)
                             , '* sin( pi * ( Tag /'
                             , 365 + leap_year(J)
                             , '- 0.5 ) ) +',  round(CT$b[1],2) )
         , x ='Tag ab 21.12.'
         , y ='Energie [kWh]'
         , colour = 'Legende'
         , caption = citation ) +
  theme_ipsum() +
  theme ( axis.text.x = element_text( angle = 90 ) ) -> p

ggsave(  file = paste( outdir, 'RA-Solar_', J, 'e.png', sep = '')
         , plot = p
         , bg = "white"
         , width = 1920
         , height = 1080
         , units = "px"
         , dpi = 144 )