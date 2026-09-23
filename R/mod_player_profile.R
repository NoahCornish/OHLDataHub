# ============================================================
# OHL DATA HUB
# PLAYER PROFILE MODULE
# ============================================================


# ============================================================
# UI
# ============================================================

mod_player_profile_ui <- function(id) {

  ns <- NS(id)

  div(
    class = "page-container player-profile-page",

    # --------------------------------------------------------
    # PAGE HEADER
    # --------------------------------------------------------

    div(
      class = "player-profile-page-header",

      h1("Player Profiles"),

      p(
        paste(
          "Search the complete OHL archive and explore",
          "a player's season-by-season career."
        )
      )
    ),


    # --------------------------------------------------------
    # PLAYER SEARCH
    # --------------------------------------------------------

    div(
      class = "player-search-card",

      div(
        class = "player-search-label",
        "PLAYER SEARCH"
      ),

      selectizeInput(
        inputId = ns("player"),
        label = NULL,
        choices = NULL,

        options = list(
          placeholder = "Start typing a player's name...",
          openOnFocus = FALSE,
          closeAfterSelect = TRUE,
          create = FALSE,
          maxOptions = 500
        )
      ),

      div(
        class = "player-search-help",
        "Search by first name or last name."
      )
    ),


    # --------------------------------------------------------
    # PROFILE CONTENT
    # --------------------------------------------------------

    uiOutput(
      ns("player_summary")
    ),


    conditionalPanel(
      condition = sprintf(
        "input['%s']",
        ns("player")
      ),

      # ------------------------------------------------------
      # SCORING PROGRESSION
      # ------------------------------------------------------

      div(
        class = "player-profile-section",

        div(
          class = "player-section-heading",

          div(
            h2("Scoring Progression"),

            p(
              paste(
                "Regular-season points-per-game production",
                "throughout the player's OHL career."
              )
            )
          )
        ),

        div(
          class = "player-chart-card",

          plotOutput(
            ns("career_chart"),
            height = "310px"
          )
        )
      ),


      # ------------------------------------------------------
      # SEASON HISTORY
      # ------------------------------------------------------

      div(
        class = "player-profile-section",

        div(
          class = "player-section-heading",

          div(
            h2("Season History"),

            p(
              paste(
                "Regular season, playoff, and preseason",
                "appearances available in the archive."
              )
            )
          )
        ),

        div(
          class = "player-history-card",

          div(
            class = "table-scroll",

            reactableOutput(
              ns("career_table")
            )
          )
        )
      )
    )
  )
}



# ============================================================
# SERVER
# ============================================================

mod_player_profile_server <- function(
    id,
    season_choices
) {

  moduleServer(
    id,
    function(input, output, session) {


      # ======================================================
      # LOAD PLAYER DIRECTORY
      # ======================================================

      player_directory <- load_player_directory()


      # ======================================================
      # CLEAN DIRECTORY
      # ======================================================

      player_directory$PlayerID <- as.character(
        player_directory$PlayerID
      )


      player_directory$SeasonID_numeric <- suppressWarnings(
        as.numeric(
          player_directory$SeasonID
        )
      )


      player_directory <- player_directory[
        order(
          player_directory$PlayerID,
          -player_directory$SeasonID_numeric
        ),
        ,
        drop = FALSE
      ]


      # Keep the newest directory row for each player
      latest_players <- player_directory[
        !duplicated(
          player_directory$PlayerID
        ),
        ,
        drop = FALSE
      ]


      latest_players <- latest_players[
        !is.na(latest_players$Name) &
          nzchar(latest_players$Name),
        ,
        drop = FALSE
      ]


      # ======================================================
      # HANDLE DUPLICATE PLAYER NAMES
      # ======================================================

      duplicate_names <- latest_players$Name[
        duplicated(latest_players$Name) |
          duplicated(
            latest_players$Name,
            fromLast = TRUE
          )
      ]


      latest_players$SearchLabel <- latest_players$Name


      duplicate_rows <- latest_players$Name %in% duplicate_names


      if (
        any(duplicate_rows)
      ) {

        duplicate_team <- latest_players$Team

        duplicate_team[
          is.na(duplicate_team) |
            !nzchar(duplicate_team)
        ] <- "OHL"


        latest_players$SearchLabel[
          duplicate_rows
        ] <- paste0(
          latest_players$Name[
            duplicate_rows
          ],
          " — ",
          duplicate_team[
            duplicate_rows
          ]
        )
      }


      latest_players <- latest_players[
        order(
          latest_players$Name
        ),
        ,
        drop = FALSE
      ]


      # ======================================================
      # PLAYER SEARCH
      # ======================================================

      observe({

        player_choices <- stats::setNames(
          latest_players$PlayerID,
          latest_players$SearchLabel
        )


        updateSelectizeInput(
          session,
          "player",
          choices = player_choices,
          selected = character(0),
          server = TRUE
        )
      })


      # ======================================================
      # SELECTED PLAYER DIRECTORY DATA
      # ======================================================

      selected_player_directory <- reactive({

        req(
          input$player
        )


        rows <- player_directory[
          player_directory$PlayerID == input$player,
          ,
          drop = FALSE
        ]


        req(
          nrow(rows) > 0
        )


        rows <- rows[
          order(
            -rows$SeasonID_numeric
          ),
          ,
          drop = FALSE
        ]


        rows
      })


      # ======================================================
      # SELECTED PLAYER IDENTITY
      # ======================================================

      selected_player <- reactive({

        rows <- selected_player_directory()


        rows[
          1,
          ,
          drop = FALSE
        ]
      })


      # ======================================================
      # PLAYER HISTORY
      # ======================================================

      player_history <- reactive({

        directory_rows <- selected_player_directory()


        player_name <- as.character(
          directory_rows$Name[1]
        )


        # Only search seasons associated with THIS PlayerID.
        # This greatly reduces the chance of mixing players
        # who happen to share the same name.
        player_seasons <- unique(
          as.character(
            directory_rows$Season
          )
        )


        player_seasons <- season_choices[
          season_choices %in% player_seasons
        ]


        history <- load_player_history(
          player_name = player_name,
          season_choices = player_seasons
        )


        req(
          nrow(history) > 0
        )


        history$SeasonType <- ifelse(

          grepl(
            "Playoffs",
            history$Season,
            ignore.case = TRUE
          ),

          "Playoffs",

          ifelse(

            grepl(
              "Pre-Season",
              history$Season,
              ignore.case = TRUE
            ),

            "Preseason",

            "Regular Season"
          )
        )


        history$SeasonYear <- suppressWarnings(
          as.numeric(
            sub(
              " .*",
              "",
              history$Season
            )
          )
        )


        history
      })


      # ======================================================
      # HELPERS
      # ======================================================

      get_first_value <- function(
    data,
    column
      ) {

        if (
          !column %in% names(data)
        ) {
          return("—")
        }


        values <- as.character(
          data[[column]]
        )


        values <- values[
          !is.na(values) &
            nzchar(values)
        ]


        if (
          length(values) == 0
        ) {
          return("—")
        }


        values[1]
      }


      get_numeric_vector <- function(
    data,
    column
      ) {

        if (
          !column %in% names(data)
        ) {

          return(
            rep(
              NA_real_,
              nrow(data)
            )
          )
        }


        suppressWarnings(
          as.numeric(
            as.character(
              data[[column]]
            )
          )
        )
      }


      sum_stat <- function(
    data,
    column
      ) {

        values <- get_numeric_vector(
          data,
          column
        )


        if (
          length(values) == 0 ||
          all(is.na(values))
        ) {

          return(
            NA_real_
          )
        }


        sum(
          values,
          na.rm = TRUE
        )
      }


      format_stat <- function(value) {

        if (
          is.na(value) ||
          !is.finite(value)
        ) {
          return("—")
        }


        format(
          value,
          trim = TRUE,
          scientific = FALSE,
          big.mark = ","
        )
      }


      format_rate <- function(value) {

        if (
          is.na(value) ||
          !is.finite(value)
        ) {
          return("—")
        }


        sprintf(
          "%.2f",
          value
        )
      }


      initials <- function(name) {

        if (
          is.null(name) ||
          is.na(name) ||
          name == ""
        ) {
          return("?")
        }


        pieces <- strsplit(
          name,
          "\\s+"
        )[[1]]


        paste0(
          substr(
            pieces,
            1,
            1
          ),
          collapse = ""
        )
      }


      # ======================================================
      # PLAYER SUMMARY
      # ======================================================

      output$player_summary <- renderUI({

        history <- player_history()

        directory_player <- selected_player()


        regular <- history[
          history$SeasonType == "Regular Season",
          ,
          drop = FALSE
        ]


        playoffs <- history[
          history$SeasonType == "Playoffs",
          ,
          drop = FALSE
        ]


        # ----------------------------------------------------
        # IDENTITY
        # ----------------------------------------------------

        player_name <- as.character(
          directory_player$Name[1]
        )


        player_id <- as.character(
          directory_player$PlayerID[1]
        )


        headshot_url <- as.character(
          directory_player$HeadshotURL[1]
        )


        latest_team <- as.character(
          directory_player$Team[1]
        )


        if (
          is.na(latest_team) ||
          !nzchar(latest_team)
        ) {

          latest_team <- get_first_value(
            history,
            "Team"
          )
        }


        position <- as.character(
          directory_player$Position[1]
        )


        if (
          is.na(position) ||
          !nzchar(position)
        ) {

          position <- get_first_value(
            history,
            "Pos"
          )
        }


        birth_date <- get_first_value(
          history,
          "BD"
        )


        height <- get_first_value(
          history,
          "Hgt"
        )


        weight <- get_first_value(
          history,
          "Wgt"
        )


        jersey <- get_first_value(
          history,
          "JN"
        )


        regular_seasons <- length(
          unique(
            regular$Season
          )
        )


        # ----------------------------------------------------
        # REGULAR-SEASON TOTALS
        # ----------------------------------------------------

        career_gp <- sum_stat(
          regular,
          "GP"
        )


        career_goals <- sum_stat(
          regular,
          "G"
        )


        career_assists <- sum_stat(
          regular,
          "A"
        )


        career_points <- sum_stat(
          regular,
          "PTS"
        )


        career_pim <- sum_stat(
          regular,
          "PIM"
        )


        career_ppg <- if (
          !is.na(career_gp) &&
          career_gp > 0 &&
          !is.na(career_points)
        ) {

          career_points / career_gp

        } else {

          NA_real_
        }


        # ----------------------------------------------------
        # PLAYOFF TOTALS
        # ----------------------------------------------------

        playoff_gp <- sum_stat(
          playoffs,
          "GP"
        )


        playoff_goals <- sum_stat(
          playoffs,
          "G"
        )


        playoff_assists <- sum_stat(
          playoffs,
          "A"
        )


        playoff_points <- sum_stat(
          playoffs,
          "PTS"
        )


        tagList(

          # ==================================================
          # HERO
          # ==================================================

          div(
            class = "player-profile-hero",

            div(
              class = "player-profile-main",


              # ----------------------------------------------
              # REAL OHL HEADSHOT
              # ----------------------------------------------

              div(
                class = "player-profile-photo-shell",

                div(
                  class = "player-profile-photo-fallback",

                  initials(
                    player_name
                  )
                ),

                if (
                  !is.na(headshot_url) &&
                  nzchar(headshot_url)
                ) {

                  tags$img(
                    src = headshot_url,

                    class = "player-profile-headshot",

                    alt = paste(
                      player_name,
                      "OHL headshot"
                    ),

                    onerror = paste0(
                      "this.style.display='none';"
                    )
                  )

                } else {

                  NULL
                }
              ),


              # ----------------------------------------------
              # IDENTITY
              # ----------------------------------------------

              div(
                class = "player-profile-identity",

                span(
                  class = "player-profile-eyebrow",

                  paste(
                    regular_seasons,
                    ifelse(
                      regular_seasons == 1,
                      "REGULAR SEASON",
                      "REGULAR SEASONS"
                    )
                  )
                ),

                h1(
                  player_name
                ),

                div(
                  class = "player-profile-team",

                  latest_team,

                  span(
                    class = "player-profile-divider",
                    "•"
                  ),

                  position
                ),

                div(
                  class = "player-profile-id",

                  paste0(
                    "OHL Player ID ",
                    player_id
                  )
                )
              )
            ),


            # ------------------------------------------------
            # BIO
            # ------------------------------------------------

            div(
              class = "player-profile-bio-grid",

              div(
                class = "player-profile-bio-item",

                span(
                  class = "player-profile-bio-label",
                  "Birth Date"
                ),

                span(
                  class = "player-profile-bio-value",
                  birth_date
                )
              ),

              div(
                class = "player-profile-bio-item",

                span(
                  class = "player-profile-bio-label",
                  "Position"
                ),

                span(
                  class = "player-profile-bio-value",
                  position
                )
              ),

              div(
                class = "player-profile-bio-item",

                span(
                  class = "player-profile-bio-label",
                  "Height"
                ),

                span(
                  class = "player-profile-bio-value",
                  height
                )
              ),

              div(
                class = "player-profile-bio-item",

                span(
                  class = "player-profile-bio-label",
                  "Weight"
                ),

                span(
                  class = "player-profile-bio-value",

                  if (
                    weight == "—"
                  ) {
                    weight
                  } else {
                    paste0(
                      weight,
                      " lb"
                    )
                  }
                )
              ),

              div(
                class = "player-profile-bio-item",

                span(
                  class = "player-profile-bio-label",
                  "Jersey"
                ),

                span(
                  class = "player-profile-bio-value",
                  jersey
                )
              )
            )
          ),


          # ==================================================
          # REGULAR-SEASON CAREER
          # ==================================================

          div(
            class = "player-profile-section",

            div(
              class = "player-section-heading",

              div(
                h2("Regular Season Career"),

                p(
                  "Career totals from OHL regular-season play."
                )
              )
            ),


            div(
              class = "player-career-stat-grid",

              div(
                class = "player-career-stat featured",

                span(
                  class = "player-career-stat-label",
                  "Points"
                ),

                span(
                  class = "player-career-stat-value",
                  format_stat(
                    career_points
                  )
                )
              ),

              div(
                class = "player-career-stat",

                span(
                  class = "player-career-stat-label",
                  "Games"
                ),

                span(
                  class = "player-career-stat-value",
                  format_stat(
                    career_gp
                  )
                )
              ),

              div(
                class = "player-career-stat",

                span(
                  class = "player-career-stat-label",
                  "Goals"
                ),

                span(
                  class = "player-career-stat-value",
                  format_stat(
                    career_goals
                  )
                )
              ),

              div(
                class = "player-career-stat",

                span(
                  class = "player-career-stat-label",
                  "Assists"
                ),

                span(
                  class = "player-career-stat-value",
                  format_stat(
                    career_assists
                  )
                )
              ),

              div(
                class = "player-career-stat",

                span(
                  class = "player-career-stat-label",
                  "Points / Game"
                ),

                span(
                  class = "player-career-stat-value",
                  format_rate(
                    career_ppg
                  )
                )
              ),

              div(
                class = "player-career-stat",

                span(
                  class = "player-career-stat-label",
                  "PIM"
                ),

                span(
                  class = "player-career-stat-value",
                  format_stat(
                    career_pim
                  )
                )
              )
            )
          ),


          # ==================================================
          # PLAYOFF SUMMARY
          # ==================================================

          if (
            nrow(playoffs) > 0
          ) {

            div(
              class = "player-playoff-card",

              div(
                class = "player-playoff-heading",

                span(
                  class = "player-playoff-kicker",
                  "POSTSEASON"
                ),

                h3(
                  "OHL Playoff Career"
                )
              ),

              div(
                class = "player-playoff-stats",

                div(
                  span("GP"),

                  strong(
                    format_stat(
                      playoff_gp
                    )
                  )
                ),

                div(
                  span("G"),

                  strong(
                    format_stat(
                      playoff_goals
                    )
                  )
                ),

                div(
                  span("A"),

                  strong(
                    format_stat(
                      playoff_assists
                    )
                  )
                ),

                div(
                  span("PTS"),

                  strong(
                    format_stat(
                      playoff_points
                    )
                  )
                )
              )
            )

          } else {

            NULL
          }
        )
      })


      # ======================================================
      # CAREER SCORING CHART
      # ======================================================

      output$career_chart <- renderPlot({

        history <- player_history()


        regular <- history[
          history$SeasonType == "Regular Season",
          ,
          drop = FALSE
        ]


        validate(
          need(
            nrow(regular) > 0,
            "No regular-season history available."
          )
        )


        regular$GP_numeric <- get_numeric_vector(
          regular,
          "GP"
        )


        regular$PTS_numeric <- get_numeric_vector(
          regular,
          "PTS"
        )


        regular$PPG <- ifelse(
          regular$GP_numeric > 0,
          regular$PTS_numeric / regular$GP_numeric,
          NA_real_
        )


        regular <- regular[
          is.finite(
            regular$PPG
          ),
          ,
          drop = FALSE
        ]


        validate(
          need(
            nrow(regular) > 0,
            "No scoring-rate data available."
          )
        )


        regular <- regular[
          order(
            regular$SeasonYear
          ),
          ,
          drop = FALSE
        ]


        regular$SeasonLabel <- sub(
          " Season$",
          "",
          regular$Season
        )


        regular$SeasonLabel <- factor(
          regular$SeasonLabel,
          levels = regular$SeasonLabel
        )


        ggplot2::ggplot(
          regular,

          ggplot2::aes(
            x = SeasonLabel,
            y = PPG,
            group = 1
          )
        ) +

          ggplot2::geom_line(
            linewidth = 1.2,
            colour = "#526B84"
          ) +

          ggplot2::geom_point(
            size = 4,
            colour = "#20AD9C"
          ) +

          ggplot2::geom_text(
            ggplot2::aes(
              label = sprintf(
                "%.2f",
                PPG
              )
            ),

            vjust = -0.9,
            size = 4,
            fontface = "bold",
            colour = "#2D4258"
          ) +

          ggplot2::scale_y_continuous(
            limits = c(
              0,
              NA
            ),

            expand = ggplot2::expansion(
              mult = c(
                0,
                0.18
              )
            )
          ) +

          ggplot2::labs(
            x = NULL,
            y = "Points / Game"
          ) +

          ggplot2::theme_minimal(
            base_size = 13
          ) +

          ggplot2::theme(

            panel.grid.major.x =
              ggplot2::element_blank(),

            panel.grid.minor =
              ggplot2::element_blank(),

            panel.grid.major.y =
              ggplot2::element_line(
                colour = "#E6EBF0",
                linewidth = 0.5
              ),

            axis.text.x =
              ggplot2::element_text(
                colour = "#44576A",
                face = "bold"
              ),

            axis.text.y =
              ggplot2::element_text(
                colour = "#71808F"
              ),

            axis.title.y =
              ggplot2::element_text(
                colour = "#71808F",

                margin = ggplot2::margin(
                  r = 12
                )
              ),

            plot.margin =
              ggplot2::margin(
                15,
                20,
                10,
                10
              )
          )
      })


      # ======================================================
      # SEASON HISTORY TABLE
      # ======================================================

      output$career_table <- renderReactable({

        history <- player_history()


        display_data <- data.frame(

          Season = history$Season,

          Type = history$SeasonType,

          Team = if (
            "Team" %in% names(history)
          ) {
            history$Team
          } else {
            NA
          },

          Pos = if (
            "Pos" %in% names(history)
          ) {
            history$Pos
          } else {
            NA
          },

          GP = get_numeric_vector(
            history,
            "GP"
          ),

          G = get_numeric_vector(
            history,
            "G"
          ),

          A = get_numeric_vector(
            history,
            "A"
          ),

          PTS = get_numeric_vector(
            history,
            "PTS"
          ),

          Pts.G = get_numeric_vector(
            history,
            "Pts.G"
          ),

          PIM = get_numeric_vector(
            history,
            "PIM"
          ),

          stringsAsFactors = FALSE
        )


        display_data$Season <- sub(
          " Pre-Season$",
          "",
          display_data$Season
        )


        display_data$Season <- sub(
          " Playoffs$",
          "",
          display_data$Season
        )


        display_data$Season <- sub(
          " Season$",
          "",
          display_data$Season
        )


        reactable(

          display_data,

          sortable = TRUE,
          searchable = FALSE,
          pagination = FALSE,

          striped = FALSE,
          highlight = TRUE,
          bordered = FALSE,

          compact = FALSE,
          fullWidth = TRUE,

          defaultColDef = colDef(
            minWidth = 75,
            align = "center",

            headerStyle = list(
              fontWeight = "700",
              color = "#627181",
              background = "#F7F9FB"
            )
          ),

          columns = list(

            Season = colDef(
              name = "Season",
              minWidth = 90,
              align = "left",

              style = list(
                fontWeight = "700",
                color = "#263A4D"
              )
            ),

            Type = colDef(
              name = "Type",
              minWidth = 130,
              align = "left",

              cell = function(value) {

                badge_class <- switch(
                  value,

                  "Regular Season" =
                    "season-type-badge regular",

                  "Playoffs" =
                    "season-type-badge playoffs",

                  "Preseason" =
                    "season-type-badge preseason",

                  "season-type-badge"
                )


                span(
                  class = badge_class,
                  value
                )
              }
            ),

            Team = colDef(
              name = "Team",
              minWidth = 170,
              align = "left"
            ),

            Pos = colDef(
              name = "Pos",
              minWidth = 65
            ),

            GP = colDef(
              name = "GP",
              minWidth = 65
            ),

            G = colDef(
              name = "G",
              minWidth = 60
            ),

            A = colDef(
              name = "A",
              minWidth = 60
            ),

            PTS = colDef(
              name = "PTS",
              minWidth = 70,

              style = list(
                fontWeight = "800",
                color = "#23384A"
              )
            ),

            Pts.G = colDef(
              name = "PTS/GP",
              minWidth = 85,

              format = colFormat(
                digits = 2
              )
            ),

            PIM = colDef(
              name = "PIM",
              minWidth = 70
            )
          ),

          theme = reactableTheme(
            borderColor = "#E7ECF0",
            highlightColor = "#F5F8FA",
            cellPadding = "12px 14px",

            style = list(
              fontSize = "0.92rem"
            )
          )
        )
      })
    }
  )
}
