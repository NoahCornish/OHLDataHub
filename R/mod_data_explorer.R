# OHL Data Hub
# Data Explorer Module

mod_data_explorer_ui <- function(id) {

  ns <- NS(id)

  div(
    class = "page-container",

    h2("OHL Data Explorer"),

    p(
      "Select an OHL season and dataset to view and download the available data."
    ),

    layout_columns(
      col_widths = c(6, 6),

      selectInput(
        inputId = ns("season"),
        label = "Season",
        choices = NULL
      ),

      selectInput(
        inputId = ns("dataset"),
        label = "Dataset",
        choices = c(
          "Skaters" = "skaters",
          "Goalies" = "goalies",
          "Even Strength" = "ev",
          "Short Handed" = "sh",
          "Rookies" = "rookies",
          "Draft Eligible" = "draft"
        ),
        selected = "skaters"
      )
    ),

    div(
      class = "data-explorer-actions",

      downloadButton(
        outputId = ns("download"),
        label = "Download CSV",
        class = "btn-primary"
      )
    ),

    br(),

    card(
      class = "table-card",
      full_screen = TRUE,

      card_header(
        div(
          class = "table-title-row",

          textOutput(
            ns("table_title")
          ),

          span(
            class = "table-help",
            "Swipe horizontally on mobile to view more columns."
          )
        )
      ),

      card_body(
        div(
          class = "table-scroll",
          reactableOutput(
            ns("table")
          )
        )
      )
    )
  )
}


mod_data_explorer_server <- function(
    id,
    season_choices
) {

  moduleServer(
    id,
    function(input, output, session) {

      # -----------------------------------------
      # SEASON DROPDOWN
      # -----------------------------------------

      observe({

        updateSelectInput(
          session,
          "season",
          choices = season_choices,
          selected = "2027 Season"
        )
      })

      # -----------------------------------------
      # LOAD DATA
      # -----------------------------------------

      explorer_data <- reactive({

        req(input$season)
        req(input$dataset)

        load_ohl_data(
          season = input$season,
          dataset = input$dataset
        )
      })

      # -----------------------------------------
      # TABLE TITLE
      # -----------------------------------------

      output$table_title <- renderText({

        dataset_name <- switch(
          input$dataset,

          skaters = "Skaters",
          goalies = "Goalies",
          ev = "Even Strength",
          sh = "Short Handed",
          rookies = "Rookies",
          draft = "Draft Eligible"
        )

        paste(
          input$season,
          "-",
          dataset_name
        )
      })

      # -----------------------------------------
      # TABLE
      # -----------------------------------------

      output$table <- renderReactable({

        reactable(
          explorer_data(),

          searchable = TRUE,
          sortable = TRUE,
          filterable = TRUE,

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

          theme = reactableTheme(
            borderColor = "#e5e5e5",
            stripedColor = "#f8f9fa",
            highlightColor = "#f1f3f5",
            cellPadding = "8px 10px"
          )
        )
      })

      # -----------------------------------------
      # DOWNLOAD
      # -----------------------------------------

      output$download <- downloadHandler(

        filename = function() {

          season_name <- tolower(input$season)
          season_name <- gsub(" ", "-", season_name)

          paste0(
            "ohl-",
            season_name,
            "-",
            input$dataset,
            ".csv"
          )
        },

        content = function(file) {

          write.csv(
            explorer_data(),
            file,
            row.names = FALSE
          )
        }
      )
    }
  )
}
