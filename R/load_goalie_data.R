# OHL Data Hub
# Load goalie statistics by season

load_goalie_data <- function(season) {

  # Current season always comes from GitHub
  if (season == "2027 Season") {

    return(
      load_current_data("goalies.csv")
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
    "goalies.csv"
  )

  if (!file.exists(path)) {
    stop(
      paste(
        "Historical goalie data not found for",
        season
      )
    )
  }

  read.csv(
    path,
    stringsAsFactors = FALSE
  )
}
