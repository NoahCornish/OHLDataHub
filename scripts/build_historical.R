library(OHLpkg)

# -------------------------------------------
# OHL Data Hub
# Build historical OHL archive
# -------------------------------------------

current_season <- "2027 Season"

# Get every season supported by OHLpkg
seasons <- get_Seasons()

# Do not archive the live/current season
seasons <- seasons[
  seasons$Season != current_season,
]

# -------------------------------------------
# Helper: clean folder names
# -------------------------------------------

make_folder_name <- function(season_name) {

  folder <- tolower(season_name)

  folder <- gsub("pre-season", "preseason", folder)
  folder <- gsub(" ", "-", folder)

  folder
}

# -------------------------------------------
# Helper: safely save a dataset
# -------------------------------------------

save_dataset <- function(fetch_function, path, label) {

  tryCatch({

    data <- fetch_function()

    write.csv(
      data,
      path,
      row.names = FALSE
    )

    message("✓ ", label)

  }, error = function(e) {

    message("✗ ", label)
    message("  ", e$message)

  })
}

# -------------------------------------------
# Build archive
# -------------------------------------------

for (i in seq_len(nrow(seasons))) {

  season <- seasons$Season[i]
  season_id <- seasons$SeasonID[i]
  season_type <- seasons$SeasonType[i]

  folder_name <- make_folder_name(season)

  folder <- file.path(
    "data",
    "historical",
    folder_name
  )

  dir.create(
    folder,
    recursive = TRUE,
    showWarnings = FALSE
  )

  message("")
  message("========================================")
  message("Downloading: ", season)
  message("Season ID:   ", season_id)
  message("Type:        ", season_type)
  message("========================================")

  # -----------------------------------------
  # Skaters
  # -----------------------------------------

  save_dataset(
    function() {
      get_RawStats(
        season_name = season
      )
    },
    file.path(folder, "skaters.csv"),
    paste(season, "- skaters")
  )

  # -----------------------------------------
  # Goalies
  # -----------------------------------------

  save_dataset(
    function() {
      get_GoalieStats(
        season_name = season,
        min_games = 0
      )
    },
    file.path(folder, "goalies.csv"),
    paste(season, "- goalies")
  )

  # -----------------------------------------
  # Even-strength
  # -----------------------------------------

  save_dataset(
    function() {
      get_EVStats(
        season_name = season,
        min_games = 0
      )
    },
    file.path(folder, "ev.csv"),
    paste(season, "- even strength")
  )

  # -----------------------------------------
  # Short-handed
  # -----------------------------------------

  save_dataset(
    function() {
      get_SHStats(
        season_name = season,
        min_games = 0
      )
    },
    file.path(folder, "sh.csv"),
    paste(season, "- short handed")
  )

  # -----------------------------------------
  # Rookie stats
  # -----------------------------------------

  save_dataset(
    function() {
      get_RKStats(
        season_name = season,
        min_games = 0
      )
    },
    file.path(folder, "rookies.csv"),
    paste(season, "- rookies")
  )

  # -----------------------------------------
  # Draft eligible
  # -----------------------------------------

  save_dataset(
    function() {
      get_DYStats(
        season_name = season,
        min_games = 0
      )
    },
    file.path(folder, "draft.csv"),
    paste(season, "- draft eligible")
  )
}

message("")
message("========================================")
message("Historical OHL archive complete.")
message("========================================")
