# ============================================================
# OHL DATA HUB
# PLAYER DIRECTORY LOADER
# ============================================================


load_player_directory <- function() {

  file <- "data/player_directory.csv"


  if (
    !file.exists(file)
  ) {

    stop(
      "data/player_directory.csv could not be found."
    )
  }


  directory <- read.csv(
    file,
    stringsAsFactors = FALSE
  )


  required_columns <- c(
    "PlayerID",
    "Name",
    "HeadshotURL"
  )


  missing_columns <- setdiff(
    required_columns,
    names(directory)
  )


  if (
    length(missing_columns) > 0
  ) {

    stop(
      paste0(
        "Player directory is missing required columns: ",
        paste(
          missing_columns,
          collapse = ", "
        )
      )
    )
  }


  directory$PlayerID <- as.character(
    directory$PlayerID
  )


  directory
}
