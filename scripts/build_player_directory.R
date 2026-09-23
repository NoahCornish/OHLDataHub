# ============================================================
# OHL DATA HUB
# BUILD PLAYER DIRECTORY
# ============================================================
#
# Creates:
#   data/player_directory.csv
#
# Purpose:
#   Build a searchable OHL player directory containing the
#   unique HockeyTech PlayerID used for player headshots.
#
# ============================================================


library(OHLpkg)
library(jsonlite)


# ============================================================
# SETTINGS
# ============================================================

ohl_feed_key <- "f1aa699db3d81487"

output_file <- "data/player_directory.csv"


# ============================================================
# LOAD SUPPORTED SEASONS
# ============================================================

seasons <- OHLpkg::get_Seasons()


required_season_columns <- c(
  "Season",
  "SeasonID"
)


missing_season_columns <- setdiff(
  required_season_columns,
  names(seasons)
)


if (
  length(missing_season_columns) > 0
) {

  stop(
    paste0(
      "get_Seasons() is missing required columns: ",
      paste(
        missing_season_columns,
        collapse = ", "
      )
    )
  )
}


# ============================================================
# HELPER: SAFELY EXTRACT COLUMN
# ============================================================

safe_column <- function(
    data,
    column
) {

  if (
    column %in% names(data)
  ) {

    return(
      as.character(
        data[[column]]
      )
    )
  }


  rep(
    NA_character_,
    nrow(data)
  )
}


# ============================================================
# HELPER: DOWNLOAD ONE SEASON
# ============================================================

get_player_directory_season <- function(
    season_name,
    season_id
) {

  message(
    "Fetching player directory: ",
    season_name,
    " (",
    season_id,
    ")"
  )


  url <- paste0(
    "https://lscluster.hockeytech.com/feed/",
    "?feed=modulekit",
    "&view=statviewtype",
    "&type=topscorers",
    "&key=",
    ohl_feed_key,
    "&fmt=json",
    "&client_code=ohl",
    "&lang=en",
    "&league_code=",
    "&season_id=",
    season_id,
    "&first=0",
    "&limit=50000",
    "&sort=active",
    "&stat=all",
    "&order_direction="
  )


  json_data <- tryCatch(

    jsonlite::fromJSON(
      url,
      simplifyDataFrame = TRUE
    ),

    error = function(e) {

      warning(
        paste0(
          "Could not retrieve ",
          season_name,
          ": ",
          e$message
        )
      )

      return(
        NULL
      )
    }
  )


  if (
    is.null(json_data)
  ) {

    return(
      NULL
    )
  }


  raw_data <- tryCatch(

    json_data[["SiteKit"]][["Statviewtype"]],

    error = function(e) {
      NULL
    }
  )


  if (
    is.null(raw_data) ||
    !is.data.frame(raw_data) ||
    nrow(raw_data) == 0
  ) {

    warning(
      paste0(
        "No player directory data found for ",
        season_name,
        "."
      )
    )

    return(
      NULL
    )
  }


  # ----------------------------------------------------------
  # PLAYER ID IS REQUIRED
  # ----------------------------------------------------------

  if (
    !"player_id" %in% names(raw_data)
  ) {

    warning(
      paste0(
        "No player_id column found for ",
        season_name,
        ". Available columns: ",
        paste(
          names(raw_data),
          collapse = ", "
        )
      )
    )

    return(NULL)
}

# ----------------------------------------------------------
# BUILD CLEAN PLAYER DIRECTORY
# ----------------------------------------------------------

player_id <- safe_column(
  raw_data,
  "player_id"
)


directory <- data.frame(

  PlayerID = player_id,

  Name = safe_column(
    raw_data,
    "name"
  ),

  FirstName = safe_column(
    raw_data,
    "first_name"
  ),

  LastName = safe_column(
    raw_data,
    "last_name"
  ),

  Team = safe_column(
    raw_data,
    "team_name"
  ),

  Position = safe_column(
    raw_data,
    "position"
  ),

  BirthDate = safe_column(
    raw_data,
    "birthdate"
  ),

  Season = rep(
    season_name,
    nrow(raw_data)
  ),

  SeasonID = rep(
    season_id,
    nrow(raw_data)
  ),

  stringsAsFactors = FALSE
)


# ----------------------------------------------------------
# CREATE HEADSHOT URL
# ----------------------------------------------------------

directory$HeadshotURL <- ifelse(

  !is.na(directory$PlayerID) &
    nzchar(directory$PlayerID),

  paste0(
    "https://assets.leaguestat.com/ohl/240x240/",
    directory$PlayerID,
    ".jpg"
  ),

  NA_character_
)


# ----------------------------------------------------------
# REMOVE INVALID ROWS
# ----------------------------------------------------------

directory <- directory[
  !is.na(directory$PlayerID) &
    nzchar(directory$PlayerID) &
    !is.na(directory$Name) &
    nzchar(directory$Name),
  ,
  drop = FALSE
]


# ----------------------------------------------------------
# REMOVE DUPLICATES WITHIN SEASON
# ----------------------------------------------------------

directory <- directory[
  !duplicated(
    directory[
      c(
        "PlayerID",
        "SeasonID"
      )
    ]
  ),
  ,
  drop = FALSE
]


rownames(
  directory
) <- NULL


directory
  }


  # ============================================================
  # BUILD DIRECTORY FOR ALL SUPPORTED SEASONS
  # ============================================================

  directory_list <- list()


  for (
    i in seq_len(
      nrow(seasons)
    )
  ) {

    season_name <- as.character(
      seasons$Season[i]
    )


    season_id <- as.character(
      seasons$SeasonID[i]
    )


    season_directory <- get_player_directory_season(
      season_name = season_name,
      season_id = season_id
    )


    if (
      !is.null(season_directory) &&
      nrow(season_directory) > 0
    ) {

      directory_list[[length(directory_list) + 1]] <- season_directory
    }
  }


  # ============================================================
  # VERIFY RESULTS
  # ============================================================

  if (
    length(directory_list) == 0
  ) {

    stop(
      "No player directory data could be retrieved."
    )
  }


  # ============================================================
  # COMBINE ALL SEASONS
  # ============================================================

  player_directory <- do.call(
    rbind,
    directory_list
  )


  rownames(
    player_directory
  ) <- NULL


  # ============================================================
  # CLEAN PLAYER IDs
  # ============================================================

  player_directory$PlayerID <- as.character(
    player_directory$PlayerID
  )


  # ============================================================
  # SORT DIRECTORY
  # ============================================================

  player_directory <- player_directory[
    order(
      player_directory$Name,
      -suppressWarnings(
        as.numeric(
          player_directory$SeasonID
        )
      )
    ),
    ,
    drop = FALSE
  ]


  rownames(
    player_directory
  ) <- NULL


  # ============================================================
  # CREATE OUTPUT DIRECTORY IF NEEDED
  # ============================================================

  if (
    !dir.exists("data")
  ) {

    dir.create(
      "data",
      recursive = TRUE
    )
  }


  # ============================================================
  # WRITE PLAYER DIRECTORY
  # ============================================================

  write.csv(
    player_directory,
    output_file,
    row.names = FALSE,
    na = ""
  )


  # ============================================================
  # SUMMARY
  # ============================================================

  unique_players <- length(
    unique(
      player_directory$PlayerID
    )
  )


  unique_names <- length(
    unique(
      player_directory$Name
    )
  )


  message("")
  message(
    "============================================"
  )

  message(
    "OHL PLAYER DIRECTORY COMPLETE"
  )

  message(
    "============================================"
  )

  message(
    "Rows: ",
    nrow(player_directory)
  )

  message(
    "Unique Player IDs: ",
    unique_players
  )

  message(
    "Unique Player Names: ",
    unique_names
  )

  message(
    "Seasons processed: ",
    length(directory_list)
  )

  message(
    "Saved to: ",
    output_file
  )

  message(
    "============================================"
  )
