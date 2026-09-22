# ============================================================
# OHL DATA HUB
# Shiny Application
# ============================================================

library(shiny)
library(bslib)
library(reactable)
library(shinymanager)


# ============================================================
# SOURCE APP FILES
# ============================================================

source("R/load_current_data.R")
source("R/load_skater_data.R")
source("R/load_goalie_data.R")
source("R/load_ohl_data.R")
source("R/mod_player_compare.R")
#source("R/mod_data_explorer.R")


# ============================================================
# LOGIN CREDENTIALS
# ============================================================

credentials <- data.frame(
  user = Sys.getenv("OHL_APP_USER"),
  password = Sys.getenv("OHL_APP_PASSWORD"),
  stringsAsFactors = FALSE
)

# Prevent accidentally launching without credentials
# ============================================================
# LOGIN CREDENTIALS
# ============================================================

if (!file.exists("credentials.rds")) {
  stop(
    "credentials.rds is missing. The application cannot start."
  )
}

credentials <- readRDS(
  "credentials.rds"
)


# ============================================================
# AVAILABLE SEASONS
# ============================================================

season_choices <- c(
  "2027 Season",
  "2026 Pre-Season",
  "2026 Playoffs",
  "2026 Season",
  "2025 Pre-Season",
  "2025 Playoffs",
  "2025 Season",
  "2024 Playoffs",
  "2024 Season",
  "2024 Pre-Season",
  "2023 Playoffs",
  "2023 Season",
  "2022 Playoffs",
  "2022 Season",
  "2020 Season",
  "2019 Playoffs",
  "2019 Season",
  "2018 Playoffs",
  "2018 Season",
  "2017 Playoffs",
  "2017 Season",
  "2016 Playoffs",
  "2016 Season",
  "2015 Playoffs",
  "2015 Season",
  "2014 Playoffs",
  "2014 Season",
  "2013 Playoffs",
  "2013 Season",
  "2012 Playoffs",
  "2012 Season",
  "2011 Playoffs",
  "2011 Season",
  "2010 Playoffs",
  "2010 Season",
  "2009 Playoffs",
  "2009 Season",
  "2008 Playoffs",
  "2008 Season",
  "2007 Playoffs",
  "2007 Season",
  "2006 Playoffs",
  "2006 Season",
  "2005 Playoffs",
  "2005 Season",
  "2004 Playoffs",
  "2004 Season",
  "2003 Playoffs",
  "2003 Season",
  "2002 Playoffs",
  "2002 Season",
  "2001 Playoffs",
  "2001 Season",
  "2000 Playoffs",
  "2000 Season",
  "1999 Playoffs",
  "1999 Season",
  "1998 Playoffs",
  "1998 Season"
)


# ============================================================
# APPLICATION UI
# ============================================================

app_ui <- page_navbar(

  title = "OHL Data Hub",

  theme = bs_theme(
    version = 5,
    bootswatch = "flatly"
  ),

  header = tags$head(
    includeCSS("www/styles.css")
  ),


  # ==========================================================
  # HOME
  # ==========================================================

  nav_panel(

    "Home",

    div(

      class = "page-container",

      h1("OHL Data Hub"),

      p(
        "Explore, visualize, and download Ontario Hockey League data."
      ),

      layout_column_wrap(

        width = 1 / 2,

        value_box(
          title = "Current Season",
          value = "2026-27"
        ),

        value_box(
          title = "Players",
          value = textOutput("player_count")
        )
      ),

      card(

        card_header(
          "About OHL Data Hub"
        ),

        card_body(

          p(
            paste(
              "OHL Data Hub provides access to current",
              "and historical Ontario Hockey League statistics."
            )
          ),

          p(
            "Current-season data is updated automatically throughout the day."
          ),

          p(
            "Powered by OHLpkg and OHLviz."
          )
        )
      )
    )
  ),


  # ==========================================================
  # DATA EXPLORER
  # ==========================================================

#  nav_panel(

#    "Data Explorer",

#    mod_data_explorer_ui(
#      "data_explorer"
#    )
#  ),

# ==========================================================
# Player Compare
# ==========================================================

nav_panel(
  "Compare Players",

  mod_player_compare_ui(
    "player_compare"
  )
),

  # ==========================================================
  # SKATERS
  # ==========================================================

  nav_panel(

    "Skaters",

    div(

      class = "page-container",

      h2("OHL Skater Statistics"),

      p(
        paste(
          "Search, sort, and customize current",
          "and historical OHL player statistics."
        )
      ),

      layout_columns(

        col_widths = c(6, 6),

        selectInput(
          inputId = "skater_season",
          label = "Season",
          choices = season_choices,
          selected = "2027 Season"
        ),

        div(

          style = "padding-top: 31px;",

          actionButton(
            inputId = "choose_skater_stats",
            label = "Choose Stats",
            class = "btn-primary"
          )
        )
      ),

      card(

        class = "table-card",

        full_screen = TRUE,

        card_header(

          div(

            class = "table-title-row",

            textOutput(
              "skater_table_title"
            ),

            span(
              class = "table-help",
              "Swipe horizontally on mobile to view more statistics."
            )
          )
        ),

        card_body(

          div(

            class = "table-scroll",

            reactableOutput(
              "skater_table"
            )
          )
        )
      )
    )
  ),


  # ==========================================================
  # GOALIES
  # ==========================================================

  nav_panel(

    "Goalies",

    div(

      class = "page-container",

      h2("OHL Goaltender Statistics"),

      p(
        paste(
          "Search, sort, and customize current",
          "and historical OHL goaltender statistics."
        )
      ),

      layout_columns(

        col_widths = c(6, 6),

        selectInput(
          inputId = "goalie_season",
          label = "Season",
          choices = season_choices,
          selected = "2027 Season"
        ),

        div(

          style = "padding-top: 31px;",

          actionButton(
            inputId = "choose_goalie_stats",
            label = "Choose Stats",
            class = "btn-primary"
          )
        )
      ),

      card(

        class = "table-card",

        full_screen = TRUE,

        card_header(

          div(

            class = "table-title-row",

            textOutput(
              "goalie_table_title"
            ),

            span(
              class = "table-help",
              "Swipe horizontally on mobile to view more statistics."
            )
          )
        ),

        card_body(

          div(

            class = "table-scroll",

            reactableOutput(
              "goalie_table"
            )
          )
        )
      )
    )
  ),


  # ==========================================================
  # ABOUT
  # ==========================================================

  nav_panel(

    "About",

    div(

      class = "page-container",

      h2("About OHL Data Hub"),

      p(
        paste(
          "An independent open-source project for accessing",
          "Ontario Hockey League data."
        )
      ),

      p(
        "Powered by OHLpkg and OHLviz."
      )
    )
  )
)


# ============================================================
# PASSWORD-PROTECT ENTIRE APPLICATION
# ============================================================

ui <- secure_app(
  app_ui
)


# ============================================================
# SERVER
# ============================================================

server <- function(input, output, session) {


  # ==========================================================
  # AUTHENTICATION
  # ==========================================================

  auth <- secure_server(
    check_credentials = check_credentials(
      credentials
    )
  )


  # ==========================================================
  # HOME
  # ==========================================================

  current_skaters <- reactive({

    load_current_data(
      "skaters.csv"
    )
  })


  output$player_count <- renderText({

    nrow(
      current_skaters()
    )
  })


  # ==========================================================
  # SKATERS
  # ==========================================================

  skaters <- reactive({

    req(
      input$skater_season
    )

    load_skater_data(
      input$skater_season
    )
  })


  # ----------------------------------------------------------
  # SKATER TABLE TITLE
  # ----------------------------------------------------------

  output$skater_table_title <- renderText({

    paste(
      input$skater_season,
      "Skaters"
    )
  })


  # ----------------------------------------------------------
  # DEFAULT SKATER COLUMNS
  # ----------------------------------------------------------

  default_skater_columns <- c(
    "Name",
    "Rookie",
    "BD",
    "Pos",
    "Team",
    "GP",
    "G",
    "A",
    "PTS",
    "Pts.G",
    "PIM"
  )


  selected_skater_columns <- reactiveVal(
    default_skater_columns
  )


  # ----------------------------------------------------------
  # CHOOSE SKATER STATS
  # ----------------------------------------------------------

  observeEvent(
    input$choose_skater_stats,
    {

      available_columns <- names(
        skaters()
      )

      currently_selected <- intersect(
        selected_skater_columns(),
        available_columns
      )

      showModal(

        modalDialog(

          title = "Choose Skater Statistics",

          checkboxGroupInput(
            inputId = "skater_column_choices",
            label = NULL,
            choices = available_columns,
            selected = currently_selected
          ),

          footer = tagList(

            modalButton(
              "Cancel"
            ),

            actionButton(
              inputId = "reset_skater_columns",
              label = "Reset"
            ),

            actionButton(
              inputId = "apply_skater_columns",
              label = "Apply",
              class = "btn-primary"
            )
          ),

          easyClose = TRUE,

          size = "l"
        )
      )
    }
  )


  # ----------------------------------------------------------
  # APPLY SKATER STATS
  # ----------------------------------------------------------

  observeEvent(
    input$apply_skater_columns,
    {

      req(
        input$skater_column_choices
      )

      selected_skater_columns(
        input$skater_column_choices
      )

      removeModal()
    }
  )


  # ----------------------------------------------------------
  # RESET SKATER STATS
  # ----------------------------------------------------------

  observeEvent(
    input$reset_skater_columns,
    {

      defaults <- intersect(
        default_skater_columns,
        names(skaters())
      )

      updateCheckboxGroupInput(
        session,
        "skater_column_choices",
        selected = defaults
      )
    }
  )


  # ----------------------------------------------------------
  # DISPLAYED SKATER DATA
  # ----------------------------------------------------------

  displayed_skaters <- reactive({

    columns <- intersect(
      selected_skater_columns(),
      names(skaters())
    )

    skaters()[
      ,
      columns,
      drop = FALSE
    ]
  })


  # ----------------------------------------------------------
  # SKATER TABLE
  # ----------------------------------------------------------

  output$skater_table <- renderReactable({

    data <- displayed_skaters()

    reactable(

      data,

      searchable = TRUE,
      sortable = TRUE,

      pagination = TRUE,

      defaultPageSize = 25,

      showPageSizeOptions = TRUE,

      pageSizeOptions = c(
        10,
        25,
        50,
        100
      ),

      striped = TRUE,
      highlight = TRUE,
      bordered = FALSE,

      compact = TRUE,
      fullWidth = TRUE,

      defaultColDef = colDef(
        minWidth = 75,
        align = "center"
      ),

      columns = list(

        Name = colDef(
          minWidth = 170,
          align = "left"
        ),

        Team = colDef(
          minWidth = 120,
          align = "left"
        ),

        Rookie = colDef(
          minWidth = 80
        ),

        BD = colDef(
          minWidth = 100
        ),

        Pos = colDef(
          minWidth = 70
        )
      ),

      defaultSorted = if (
        "PTS" %in% names(data)
      ) {
        "PTS"
      } else {
        NULL
      },

      defaultSortOrder = "desc",

      theme = reactableTheme(
        borderColor = "#e5e5e5",
        stripedColor = "#f8f9fa",
        highlightColor = "#f1f3f5",
        cellPadding = "8px 10px"
      )
    )
  })


  # ==========================================================
  # GOALIES
  # ==========================================================

  goalies <- reactive({

    req(
      input$goalie_season
    )

    load_goalie_data(
      input$goalie_season
    )
  })


  # ----------------------------------------------------------
  # GOALIE TABLE TITLE
  # ----------------------------------------------------------

  output$goalie_table_title <- renderText({

    paste(
      input$goalie_season,
      "Goalies"
    )
  })


  # ----------------------------------------------------------
  # DEFAULT GOALIE COLUMNS
  # ----------------------------------------------------------

  default_goalie_columns <- c(
    "Name",
    "Team",
    "GP",
    "W",
    "L",
    "OTL",
    "GAA",
    "SV.Pct",
    "SO"
  )


  selected_goalie_columns <- reactiveVal(
    default_goalie_columns
  )


  # ----------------------------------------------------------
  # CHOOSE GOALIE STATS
  # ----------------------------------------------------------

  observeEvent(
    input$choose_goalie_stats,
    {

      available_columns <- names(
        goalies()
      )

      currently_selected <- intersect(
        selected_goalie_columns(),
        available_columns
      )

      showModal(

        modalDialog(

          title = "Choose Goaltender Statistics",

          checkboxGroupInput(
            inputId = "goalie_column_choices",
            label = NULL,
            choices = available_columns,
            selected = currently_selected
          ),

          footer = tagList(

            modalButton(
              "Cancel"
            ),

            actionButton(
              inputId = "reset_goalie_columns",
              label = "Reset"
            ),

            actionButton(
              inputId = "apply_goalie_columns",
              label = "Apply",
              class = "btn-primary"
            )
          ),

          easyClose = TRUE,

          size = "l"
        )
      )
    }
  )


  # ----------------------------------------------------------
  # APPLY GOALIE STATS
  # ----------------------------------------------------------

  observeEvent(
    input$apply_goalie_columns,
    {

      req(
        input$goalie_column_choices
      )

      selected_goalie_columns(
        input$goalie_column_choices
      )

      removeModal()
    }
  )


  # ----------------------------------------------------------
  # RESET GOALIE STATS
  # ----------------------------------------------------------

  observeEvent(
    input$reset_goalie_columns,
    {

      defaults <- intersect(
        default_goalie_columns,
        names(goalies())
      )

      updateCheckboxGroupInput(
        session,
        "goalie_column_choices",
        selected = defaults
      )
    }
  )


  # ----------------------------------------------------------
  # DISPLAYED GOALIE DATA
  # ----------------------------------------------------------

  displayed_goalies <- reactive({

    columns <- intersect(
      selected_goalie_columns(),
      names(goalies())
    )

    goalies()[
      ,
      columns,
      drop = FALSE
    ]
  })


  # ----------------------------------------------------------
  # GOALIE TABLE
  # ----------------------------------------------------------

  output$goalie_table <- renderReactable({

    data <- displayed_goalies()

    reactable(

      data,

      searchable = TRUE,
      sortable = TRUE,

      pagination = TRUE,

      defaultPageSize = 25,

      showPageSizeOptions = TRUE,

      pageSizeOptions = c(
        10,
        25,
        50,
        100
      ),

      striped = TRUE,
      highlight = TRUE,
      bordered = FALSE,

      compact = TRUE,
      fullWidth = TRUE,

      defaultColDef = colDef(
        minWidth = 80,
        align = "center"
      ),

      columns = list(

        Name = colDef(
          minWidth = 170,
          align = "left"
        ),

        Team = colDef(
          minWidth = 120,
          align = "left"
        )
      ),

      defaultSorted = if (
        "SV.Pct" %in% names(data)
      ) {
        "SV.Pct"
      } else if (
        "W" %in% names(data)
      ) {
        "W"
      } else {
        NULL
      },

      defaultSortOrder = "desc",

      theme = reactableTheme(
        borderColor = "#e5e5e5",
        stripedColor = "#f8f9fa",
        highlightColor = "#f1f3f5",
        cellPadding = "8px 10px"
      )
    )
  })


  # ==========================================================
  # DATA EXPLORER
  # ==========================================================

 # mod_data_explorer_server(
#    "data_explorer",
#    season_choices = season_choices
#  )

  mod_player_compare_server(
    "player_compare",
    season_choices = season_choices
  )
}


# ============================================================
# RUN APPLICATION
# ============================================================

shinyApp(
  ui = ui,
  server = server
)
