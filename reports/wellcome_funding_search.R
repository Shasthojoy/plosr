#' Search PLOS articles for funding information
#' Search GRIST for matching grants
#'
#' @author Martin Fenner <mfenner@plos.org>

# Options
report_date <- "2013-11-26"
start_year <- 2003
end_year <- 2013
report_name <- "wellcome_funding_search"
funder_name <- "Wellcome Trust"
search_string <- '(wellcome OR welcome) AND trust'
regex_string <- "\\b(?:WT)?0?[1-9][0-9]{4}\\b"
api_key <- "3pezRBRXdyzYW6ztfwft"
grist_url <- "http://plus.europepmc.org/GristAPI/rest/get/query=gid:"

# Read in required functions
library(rplos)
library(stringr)
library(plyr)
library(httr)

# helper function to find matching grant IDs
matchGrants <- function(text, regex_string) {
  match_list <- str_match_all(text, regex_string)
  match_vector <- unlist(match_list)
  if(identical(match_vector,character(0))) {
    match_str <- NA
  } else {
    # additional regex because of problems with capture groups
    match_vector <- gsub("^(WT|WT0|0)", "", match_vector)
    
    match_unique <- unique(match_vector)
    match_str <- paste(match_unique,collapse=";")
  }  
}

# Search for funder information
report.csv <- paste("data/articles_", report_name, "_", report_date, ".csv", sep="")
if (file.exists(report.csv)) {
  articles <- read.csv(report.csv, stringsAsFactors=FALSE, header=TRUE)
} else {
  terms <- paste('financial_disclosure:', search_string, ' AND publication_date:[', start_year, '-01-01T00:00:00Z TO ', end_year, '-12-31T23:59:59Z]', sep = "")
  response <- searchplos(terms=terms, fields='id,title,publication_date,financial_disclosure', toquery='doc_type:full', limit=10000, key=api_key)
  if(!is.null(response)) {
    # rename id column to doi
    names(response)[names(response)=="id"] <- "doi"
    
    # turn timestamp into date object
    response$publication_date <- as.Date(strptime(response$publication_date,format="%Y-%m-%dT00:00:00Z"))
    
    # title and financial_disclosure are list objects. Unlist them so that they can be saved to CSV
    # change NULL to NA, as unlist discards NULL
    response$doi <- unlist(response$doi)
    response$title <- unlist(response$title)
    response$financial_disclosure[sapply(response$financial_disclosure, is.null)] <- NA
    response$financial_disclosure <- unlist(response$financial_disclosure)
    
    articles <- response
    write.csv(articles, report.csv, row.names=FALSE, fileEncoding="utf-8")
  }
}

# Extract grant information
report.csv <- paste("data/parsed_articles_", report_name, "_", report_date, ".csv", sep="")
if (file.exists(report.csv)) {
  parsed_articles <- read.csv(report.csv, stringsAsFactors=FALSE, header=TRUE)
} else {
  n <- nrow(articles)
  parsed_articles <- data.frame()
  for (i in 1:n) {
    row <- articles[i,]
    row$grants <- matchGrants(row$financial_disclosure, regex_string)
    #row$grants <- row$grants[row$grants == ""] <-NA
    parsed_articles <- rbind(parsed_articles,row)
  }
  write.csv(parsed_articles, report.csv, row.names=FALSE, fileEncoding="utf-8")
}

# Search for grant information
# report.csv <- paste("data/grants_", report_name, "_", report_date, ".csv", sep="")
# if (file.exists(report.csv)) {
#   grants <- read.csv(report.csv, stringsAsFactors=FALSE, header=TRUE)
# } else {
#   grants <- data.frame()
#   for (i in 1:nrow(articles))  {
#     article <- articles[i,]
#     
#     # skip if no grant found
#     if (is.na(article$grant)) next
#     
#     query <- paste(grist_url, article$grant, "&format=json", sep="")
#     response <- content(GET(query)) 
#     
#     # store funder, grant ID and grant title if match found. Use rbind.fill instead of rbind to handle factors
#     if (!is.null(response$HitCount) && as.numeric(response$HitCount) == 1) {
#       grants <- rbind.fill(grants, as.data.frame(response$RecordList$Record$Grant))
#     }
#   }
#   # only keep grants that match funder name
#   grants <- subset(grants, grants$Funder == funder_name)
#   
#   # remove duplicates
#   grants <- unique(grants)
#   
#   # rename grant title column to distinguish from article title, and discard other columns
#   names(grants)[names(grants)=="Title"] <- "grant_title"
#   grants <- subset(grants, select=c("Id","grant_title"))
#   
#   write.csv(grants, report.csv, row.names=FALSE, fileEncoding="utf-8")
# }
# 
# # merge articles with grants and save as CSV
# results <- merge(articles, grants, by.x="grant", by.y="Id", all.y = TRUE)
# results <- subset(results, select=c("doi","publication_date","title","financial_disclosure","grant","grant_title"))
# report.csv <- paste("data/results_", report_name, "_", report_date, ".csv", sep="")
# write.csv(results, report.csv, row.names=FALSE, fileEncoding="utf-8")