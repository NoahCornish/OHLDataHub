# OHL Data Hub
# Universal OHL dataset loader

load_ohl_data <- function(season, dataset) {

  available_datasets <- c(
    "skaters",
    "goalies",
    "ev",
    "sh",
    "rookies",
    "draft"
  )

  if (!dataset %in% available_datasets) {
    stop(
      paste(
        "Unknown dataset:",
        dataset
      )
    )
  }

  file_name <- paste0(
    dataset,
    ".csv"
  )

  # -----------------------------------------
  # CURRENT SEASON
  # -----------------------------------------

  if (season == "2027 Season") {

    return(
      load_current_data(file_name)
    )
  }

  # -----------------------------------------
  # HISTORICAL SEASONS
  # -----------------------------------------

  folder <- tolower(season)

  folder <- gsub(
    "pre-season",
    "preseason",
    folder
  )

  folder <- gsub(
    " ",
    "-",
    folder
  )

  path <- file.path(
    "data",
    "historical",
    folder,
    file_name
  )

  if (!file.exists(path)) {
    stop(
      paste(
        dataset,
        "data not found for",
        season
      )
    )
  }

  read.csv(
    path,
    stringsAsFactors = FALSE
  )
}
