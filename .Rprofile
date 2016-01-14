#------------------------------------------------------------------------------#
#                                   Rprofile                                   #
#                                                                              #
#            Modified at Thu Dec 31 09:39:51 CST 2015 by Weihang Lo            #
#------------------------------------------------------------------------------#

#interactive load .Rprofile START
if (interactive()) {

#-----------------------------
# Autoload packages
#-----------------------------
options(warn = -1)
options(vimcom.verbose = -1)
require(vimcom)
require(colorout)
options(warn = 0)


#-----------------------------
# Autoload functions
#-----------------------------
autoload("%>>%", "pipeR")
autoload("data.table", "data.table")
autoload("fread", "data.table")
autoload("microbenchmark", "microbenchmark")
autoload("ggplot", "ggplot2")
cat("\nAutoloaded Functions...\n\n", paste("--", ls("Autoloads"), "\n"))


#-----------------------------
# Useful packages list
#-----------------------------

#---General---
# doParallel
# data.table
# microbenchmark
# rmarkdown ---> require: pandoc
#install.packages(c("doParallel", "data.table", "microbenchmark", "rmarkdown"))

#---Plot---
# rgl ---> require: freeglut-devel
# plotly
# ggplot2
# animation ---> require: ImageMagick
#install.packages(c("rgl", "plotly", "ggplot2", "animation"))

#---Spatial analysis---
# spatstat
# raster
# rgeos
# rgdal ---> require: gdal, gdal-devel, proj...
# ggmap
# leaflet
#install.packages(c("spatstat", "raster", "rgeos", "rgdal", "ggmap", "leaflet"))

#---Data I/O---
# RMySQL
# RSQLite
# RPostgreSQL
# rmongodb
# readxl
#install.packages(c("RMySQL", "RSQLite", "RPostgreSQL", "rmongodb", "readxl"))

#---Ecology---
# vegan

#---Web related---
# XML
# RCurl
# rvest
# selectr
# jsonlite
#install.packages(c("rvest", "RCurl", "XML", "selectr", "jsonlite"))

#---Machine learning---
# rpart
# party
# randomForest
# e1071
#install.packages(c("rpart", "party", "randomForest", "e1071"))

#---Text mining---
# tm
# tmcn --> on R-forge
# jiebaR
# wordcloud
# SnowballC
# LSAfun
#install.packages(c("tm", "tmcn", "jiebaR", "wordcloud", "SnowballC", "LSAfun"))

#---Scientific computing---
# rootSolve
# deSolve
#install.packages(c("rootSolve", "deSolve"))


#-----------------------------
# Set options
#-----------------------------

#---Set CRAN mirror---
local({ 
        r <- getOption("repos") 
        r["CRAN"] <- "http://cran.csie.ntu.edu.tw/"
        options(repos = r) 
})

#---Set prompt---
options(continue = ". ")


#-----------------------------
# Convenient function
#-----------------------------

#---rm all---
.rm <- function(...) rm(list=ls(1), pos=1, ...)

#---Improved ls---
.ls <- function (pos = 1, pattern, order.by, decreasing=FALSE) {
    if(length(ls(pos = pos, pattern = pattern))==0) stop("Nothing found.") 
    nply <- function(names, fn) sapply(names, function(x) fn(get(x, pos)))
    names <- ls(pos = pos, pattern = pattern)

    obj.class <- nply(names, function(x) as.character(class(x))[1])
    obj.mode <- nply(names, mode)
    obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
    obj.size <- nply(names, 
        function(x) format(utils::object.size(x), units = "auto")
    )

    obj.dim <- t(nply(names, function(x) as.numeric(dim(x))[1:2]))
    vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
    obj.dim[vec, 1] <- nply(names, length)[vec]

    out <- data.frame(obj.type, obj.size, obj.dim)
    names(out) <- c("Type", "Size", "Rows", "Columns")

    if (!missing(order.by)) out <- out[order(out[[order.by]]), ]
    out
}


#-----------------------------
# Start & Exit
#-----------------------------

.First <- function() {
    try(utils::loadhistory("~/.Rhistory"))
    cat("\n\nSuccessfully loaded .Rprofile at", date(), "\n\n")
}

.Last <- function() {
    try(utils::savehistory("~/.Rhistory"))
    cat("\nExit R session at", date(), "\n\n")
}

#interactive load .Rprofile END
}
