# ============================================================
# OHL DATA HUB
# PLAYER HISTORY LOADER
# ============================================================


load_player_history <- function(
    player_name,
    season_choices
) {

  player_history <- list()


  # ==========================================================
  # SEARCH EVERY SUPPORTED SEASON
  # ==========================================================

  for (season in season_choices) {

    season_data <- tryCatch(

      load_skater_data(
        season
      ),

      error = function(e) {
        NULL
      }
    )


    if (
      is.null(season_data) ||
      !"Name" %in% names(season_data)
    ) {
      next
    }


    player_rows <- season_data[
      season_data$Name == player_name,
      ,
      drop = FALSE
    ]


    if (
      nrow(player_rows) == 0
    ) {
      next
    }


    player_rows$Season <- season


    player_history[[length(player_history) + 1]] <- player_rows
  }


  # ==========================================================
  # NO RESULTS
  # ==========================================================

  if (
    length(player_history) == 0
  ) {

    return(
      data.frame()
    )
  }


  # ==========================================================
  # GET ALL COLUMNS FROM ALL SEASONS
  # ==========================================================

  all_columns <- unique(
    unlist(
      lapply(
        player_history,
        names
      )
    )
  )


  # ==========================================================
  # STANDARDIZE COLUMNS BETWEEN SEASONS
  # ==========================================================

  player_history <- lapply(
    player_history,
    function(data) {

      missing_columns <- setdiff(
        all_columns,
        names(data)
      )


      if (
        length(missing_columns) > 0
      ) {

        for (column in missing_columns) {

          data[[column]] <- NA
        }
      }


      data[
        ,
        all_columns,
        drop = FALSE
      ]
    }
  )


  # ==========================================================
  # COMBINE ALL SEASONS
  # ==========================================================

  history <- do.call(
    rbind,
    player_history
  )


  rownames(
    history
  ) <- NULL


  # ==========================================================
  # PUT SEASON FIRST
  # ==========================================================

  history <- history[
    ,
    c(
      "Season",
      setdiff(
        names(history),
        "Season"
      )
    ),
    drop = FALSE
  ]


  return(
    history
  )
}
