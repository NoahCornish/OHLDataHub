# ============================================================
# OHL DATA HUB
# PLAYER COMPARISON MODULE
# ============================================================


# ============================================================
# UI
# ============================================================

mod_player_compare_ui <- function(id) {

  ns <- NS(id)

  div(
    class = "page-container compare-dashboard",

    # --------------------------------------------------------
    # PAGE HEADER
    # --------------------------------------------------------

    div(
      class = "compare-page-header",

      div(
        h1("Player Comparison"),
        p(
          "Compare OHL players from any supported season."
        )
      )
    ),


    # --------------------------------------------------------
    # PLAYER SELECTORS
    # --------------------------------------------------------

    div(
      class = "compare-selector-card",

      div(
        class = "compare-selector-grid",

        # PLAYER A
        div(
          class = "compare-selector-side",

          div(
            class = "compare-selector-label",
            "PLAYER A"
          ),

          selectInput(
            inputId = ns("season_1"),
            label = "Season",
            choices = NULL
          ),

          selectizeInput(
            inputId = ns("player_1"),
            label = "Player",
            choices = NULL,
            options = list(
              placeholder = "Select player"
            )
          )
        ),


        # VS
        div(
          class = "compare-vs-column",

          div(
            class = "compare-vs-circle",
            "VS"
          )
        ),


        # PLAYER B
        div(
          class = "compare-selector-side",

          div(
            class = "compare-selector-label",
            "PLAYER B"
          ),

          selectInput(
            inputId = ns("season_2"),
            label = "Season",
            choices = NULL
          ),

          selectizeInput(
            inputId = ns("player_2"),
            label = "Player",
            choices = NULL,
            options = list(
              placeholder = "Select player"
            )
          )
        )
      )
    ),


    # --------------------------------------------------------
    # PLAYER HERO CARDS
    # --------------------------------------------------------

    uiOutput(
      ns("player_cards")
    ),


    # --------------------------------------------------------
    # HEAD TO HEAD
    # --------------------------------------------------------

    uiOutput(
      ns("stat_comparison")
    )
  )
}



# ============================================================
# SERVER
# ============================================================

mod_player_compare_server <- function(
    id,
    season_choices
) {

  moduleServer(
    id,
    function(input, output, session) {


      # ------------------------------------------------------
      # SEASON SELECTORS
      # ------------------------------------------------------

      observe({

        updateSelectInput(
          session,
          "season_1",
          choices = season_choices,
          selected = "2026 Season"
        )

        updateSelectInput(
          session,
          "season_2",
          choices = season_choices,
          selected = "2015 Season"
        )
      })


      # ------------------------------------------------------
      # LOAD SEASON DATA
      # ------------------------------------------------------

      season_1_data <- reactive({

        req(input$season_1)

        load_skater_data(
          input$season_1
        )
      })


      season_2_data <- reactive({

        req(input$season_2)

        load_skater_data(
          input$season_2
        )
      })


      # ------------------------------------------------------
      # PLAYER DROPDOWNS
      # ------------------------------------------------------

      observeEvent(
        season_1_data(),
        {

          players <- sort(
            unique(
              season_1_data()$Name
            )
          )

          selected_player <- if (
            "Nolan Laird" %in% players
          ) {
            "Nolan Laird"
          } else {
            players[1]
          }

          updateSelectizeInput(
            session,
            "player_1",
            choices = players,
            selected = selected_player,
            server = TRUE
          )
        }
      )


      observeEvent(
        season_2_data(),
        {

          players <- sort(
            unique(
              season_2_data()$Name
            )
          )

          selected_player <- if (
            "Connor McDavid" %in% players
          ) {
            "Connor McDavid"
          } else {
            players[1]
          }

          updateSelectizeInput(
            session,
            "player_2",
            choices = players,
            selected = selected_player,
            server = TRUE
          )
        }
      )


      # ------------------------------------------------------
      # PLAYER DATA
      # ------------------------------------------------------

      player_1 <- reactive({

        req(input$player_1)

        data <- season_1_data()

        data[
          data$Name == input$player_1,
          ,
          drop = FALSE
        ][1, , drop = FALSE]
      })


      player_2 <- reactive({

        req(input$player_2)

        data <- season_2_data()

        data[
          data$Name == input$player_2,
          ,
          drop = FALSE
        ][1, , drop = FALSE]
      })


      # ------------------------------------------------------
      # HELPER FUNCTIONS
      # ------------------------------------------------------

      get_value <- function(data, column) {

        if (
          column %in% names(data) &&
          !is.na(data[[column]][1])
        ) {
          as.character(
            data[[column]][1]
          )
        } else {
          "—"
        }
      }


      initials <- function(name) {

        pieces <- strsplit(
          name,
          " "
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


      # ------------------------------------------------------
      # PLAYER CARDS
      # ------------------------------------------------------

      output$player_cards <- renderUI({

        req(
          player_1(),
          player_2()
        )

        p1 <- player_1()
        p2 <- player_2()


        div(
          class = "compare-player-grid",


          # PLAYER A
          div(
            class = "compare-player-profile",

            div(
              class = "compare-player-top",

              div(
                class = "compare-avatar",
                initials(
                  get_value(
                    p1,
                    "Name"
                  )
                )
              ),

              div(
                class = "compare-player-identity",

                span(
                  class = "compare-season-tag",
                  input$season_1
                ),

                h2(
                  get_value(
                    p1,
                    "Name"
                  )
                ),

                div(
                  class = "compare-team-line",

                  get_value(
                    p1,
                    "Team"
                  ),

                  span("•"),

                  get_value(
                    p1,
                    "Pos"
                  )
                )
              )
            ),

            div(
              class = "compare-profile-details",

              div(
                span(
                  class = "detail-label",
                  "Birth Date"
                ),

                span(
                  class = "detail-value",
                  get_value(
                    p1,
                    "BD"
                  )
                )
              ),

              div(
                span(
                  class = "detail-label",
                  "Rookie"
                ),

                span(
                  class = "detail-value",
                  get_value(
                    p1,
                    "Rookie"
                  )
                )
              )
            )
          ),


          # PLAYER B
          div(
            class = "compare-player-profile",

            div(
              class = "compare-player-top",

              div(
                class = "compare-avatar",
                initials(
                  get_value(
                    p2,
                    "Name"
                  )
                )
              ),

              div(
                class = "compare-player-identity",

                span(
                  class = "compare-season-tag",
                  input$season_2
                ),

                h2(
                  get_value(
                    p2,
                    "Name"
                  )
                ),

                div(
                  class = "compare-team-line",

                  get_value(
                    p2,
                    "Team"
                  ),

                  span("•"),

                  get_value(
                    p2,
                    "Pos"
                  )
                )
              )
            ),

            div(
              class = "compare-profile-details",

              div(
                span(
                  class = "detail-label",
                  "Birth Date"
                ),

                span(
                  class = "detail-value",
                  get_value(
                    p2,
                    "BD"
                  )
                )
              ),

              div(
                span(
                  class = "detail-label",
                  "Rookie"
                ),

                span(
                  class = "detail-value",
                  get_value(
                    p2,
                    "Rookie"
                  )
                )
              )
            )
          )
        )
      })


      # ------------------------------------------------------
      # STAT COMPARISON
      # ------------------------------------------------------

      output$stat_comparison <- renderUI({

        req(
          player_1(),
          player_2()
        )

        p1 <- player_1()
        p2 <- player_2()


        stats <- list(

          list(
            column = "GP",
            label = "Games Played"
          ),

          list(
            column = "G",
            label = "Goals"
          ),

          list(
            column = "A",
            label = "Assists"
          ),

          list(
            column = "PTS",
            label = "Points"
          ),

          list(
            column = "Pts.G",
            label = "Points / Game"
          ),

          list(
            column = "PIM",
            label = "Penalty Minutes"
          )
        )


        stats <- Filter(
          function(stat) {

            stat$column %in% names(p1) &&
              stat$column %in% names(p2)
          },

          stats
        )


        stat_cards <- lapply(
          stats,
          function(stat) {

            value_1 <- get_value(
              p1,
              stat$column
            )

            value_2 <- get_value(
              p2,
              stat$column
            )


            numeric_1 <- suppressWarnings(
              as.numeric(
                value_1
              )
            )

            numeric_2 <- suppressWarnings(
              as.numeric(
                value_2
              )
            )


            max_value <- max(
              c(
                numeric_1,
                numeric_2
              ),
              na.rm = TRUE
            )


            if (
              is.infinite(max_value) ||
              max_value <= 0
            ) {
              max_value <- 1
            }


            width_1 <- if (
              is.na(numeric_1)
            ) {
              0
            } else {
              numeric_1 / max_value * 100
            }


            width_2 <- if (
              is.na(numeric_2)
            ) {
              0
            } else {
              numeric_2 / max_value * 100
            }


            div(
              class = "compare-stat-card",

              div(
                class = "compare-stat-title",
                stat$label
              ),


              div(
                class = "compare-stat-values",

                div(
                  class = "compare-stat-player",

                  span(
                    class = "compare-stat-name",
                    get_value(
                      p1,
                      "Name"
                    )
                  ),

                  span(
                    class = "compare-stat-number",
                    value_1
                  )
                ),


                div(
                  class = "compare-stat-player right",

                  span(
                    class = "compare-stat-name",
                    get_value(
                      p2,
                      "Name"
                    )
                  ),

                  span(
                    class = "compare-stat-number",
                    value_2
                  )
                )
              ),


              div(
                class = "compare-bars",

                div(
                  class = "compare-bar-track",

                  div(
                    class = "compare-bar-fill player-one",
                    style = paste0(
                      "width:",
                      width_1,
                      "%;"
                    )
                  )
                ),

                div(
                  class = "compare-bar-track",

                  div(
                    class = "compare-bar-fill player-two",
                    style = paste0(
                      "width:",
                      width_2,
                      "%;"
                    )
                  )
                )
              )
            )
          }
        )


        tagList(

          div(
            class = "compare-section-heading",

            div(
              h2("Head-to-Head"),
              p(
                "Season statistics for the selected players."
              )
            )
          ),

          div(
            class = "compare-stat-grid",
            stat_cards
          )
        )
      })
    }
  )
}
