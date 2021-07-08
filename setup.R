##################################################################################
# basic setup
##################################################################################
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # does not work with source
options(timeout = 100) # alter to suit download_data.R

##################################################################################
# install/load libraries
##################################################################################
if(!require(caret))      install.packages("caret", repos = "http://cran.us.r-project.org", dependancies = TRUE)
if(!require(ggthemes))   install.packages("ggthemes", repos = "http://cran.us.r-project.org")
if(!require(magrittr))   install.packages("magrittr", repos = "http://cran.us.r-project.org")
if(!require(rjson))      install.packages("rjson", repos = "http://cran.us.r-project.org")
if(!require(tidyverse))  install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(png))        install.packages("png", repos = "http://cran.us.r-project.org")
if(!require(grid))       install.packages("grid", repos = "http://cran.us.r-project.org")
if(!require(neighbr))    install.packages("neighbr", repos = "http://cran.us.r-project.org")
if(!require(ggcorrplot)) install.packages("ggcorrplot", repos = "http://cran.us.r-project.org")
if(!require(rpart))      install.packages("rpart", repos = "http://cran.us.r-project.org")
if(!require(rpart.plot)) install.packages("rpart.plot", repos = "http://cran.us.r-project.org")

library(caret)
library(ggthemes)
library(magrittr)
library(modiscloud)
library(rjson)
library(tidyverse)
library(png)
library(grid)
library(neighbr)
library(ggcorrplot)
library(rpart)
library(rpart.plot)
