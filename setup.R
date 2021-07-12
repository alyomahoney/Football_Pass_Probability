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
if(!require(Rborist)) install.packages("Rborist", repos = "http://cran.us.r-project.org")

library(caret)      # machine learning (decision tree and confusion matrix)
library(ggthemes)   # gdocs theme
library(magrittr)   # %$% and %<>%
#library(modiscloud) 
library(rjson)      # read .json files
library(tidyverse)  # tidyverse suite of packages
library(png)        # read .png file
library(grid)       # render raster object (for including in ggplot)
library(neighbr)    # knn with jaccard distance
library(ggcorrplot) # correlation plot
library(rpart)      # construct decision tree
library(rpart.plot) # plot decision tree algorithm
library(Rborist)    # random forest
