# OHL Data Hub
# Current-season data loader

github_base <- paste0(
  "https://raw.githubusercontent.com/",
  "NoahCornish/OHLDataHub/main/data/current/"
)

load_current_data <- function(file) {

  url <- paste0(github_base, file)

  read.csv(
    url,
    stringsAsFactors = FALSE
  )
}

load_refresh_time <- function() {

  url <- paste0(
    github_base,
    "refresh.csv"
  )

  read.csv(
    url,
    stringsAsFactors = FALSE
  )
}
