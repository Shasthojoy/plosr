library(alm)

dois <- c("10.1371/journal.pbio.1001535","10.1371/journal.pone.0046362","10.1371/journal.pmed.0020124","10.1371/journal.pntd.0001969","10.1371/journal.pone.0040259")
api_key <- "YOUR_KEY"

response <- almevents(doi=dois, source="twitter",key=api_key)

events <- data.frame()
for (i in 1:length(dois)) {
  row <- response[[i]][["twitter"]]
  row$doi <- dois[i]
  
  # remove "user_profile_image" column
  row$user_profile_image <- NULL
  
  # format "created_at" column, need to set locale
  lct <- Sys.getlocale("LC_TIME"); Sys.setlocale("LC_TIME", "C")
  if (substr(row$created_at,4,4)[[1]] == ",") {
    row$created_at <- strftime(strptime(row$created_at, "%a, %d %b %Y %H:%M:%S %z"))
  } else {
    row$created_at <- strftime(strptime(row$created_at, "%a %b %d %H:%M:%S %z %Y"))
  }
  Sys.setlocale("LC_TIME", lct)
  
  # remove linefeeds from "text" column
  row$text <- gsub("[[:space:]]+", " ", row$text)
  
  events <- rbind(events,row)
}