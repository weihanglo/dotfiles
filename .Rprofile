#-----------------------------------------------------------------------------#
#                                   Rprofile                                  #
#                                                                             #
#            Modified at Sun Dec 18 16:37:21 CST 2016 by Weihang Lo           #
#-----------------------------------------------------------------------------#

if (!interactive()) { return() }

#interactive load .Rprofile ---------------------------------------------------

# Autoload packages --------------------
if (library(colorout, logical.return = TRUE)) {
    message(base::sprintf("colorout %s loaded",
        as.character(utils::packageVersion("colorout"))))
}

if (Sys.getenv("NVIMR_TMPDIR") != "") {
    options(nvimcom.verbose = 1)
    library(nvimcom)
}

# Set options --------------------------

#---Set CRAN mirror---
local({
    r <- getOption("repos")
    r["CRAN"] <- "http://cran.csie.ntu.edu.tw/"
    options(repos = r)
})

#---Set prompt---
options(continue = ". ")

# Convenient function ------------------

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

    if (!missing(order.by)) { out <- out[order(out[[order.by]]), ] }
    out
}

# Start & Exit -------------------------

.First <- function() {
    try(utils::loadhistory("~/.Rhistory"))
    message("\n\nSuccessfully loaded .Rprofile at ", date())
}

.Last <- function() {
    try(utils::savehistory("~/.Rhistory"))
    message("\nExit R session at ", date())
}
