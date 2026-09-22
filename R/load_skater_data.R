# OHL Data Hub
# Load skater statistics by season

load_skater_data <- function(season) {

  # Current season always comes from GitHub
  if (season == "2027 Season") {

    return(
      load_current_data("skaters.csv")
    )
  }

  # Convert OHLpkg season name to historical folder name
  folder <- tolower(season)
  folder <- gsub("pre-season", "preseason", folder)
  folder <- gsub(" ", "-", folder)

  path <- file.path(
    "data",
    "historical",
    folder,
    "skaters.csv"
  )

  if (!file.exists(path)) {
    stop(
      paste(
        "Historical skater data not found for",
        season
      )
    )
  }

  read.csv(
    path,
    stringsAsFactors = FALSE
  )
}
