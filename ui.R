library(lubridate)
library(shiny)

shinyUI(
  fluidPage(
    # Application title
    titlePanel("Gantt-chart:"),
    fluidRow(
      column(3, fileInput("file_raw_plan", label = "Upload project plan:")),
      sliderInput("sl_lower_date", "Lower date", 
                  value = lubridate::as_date(lubridate::now())-30,
                  min = lubridate::as_date(lubridate::now()) - 30,
                  max = lubridate::as_date(lubridate::now()) + 60),
      sliderInput("sl_upper_date", "Upper date", 
                  value = lubridate::as_date(lubridate::now()) + 60,
                  min = lubridate::as_date(lubridate::now()) - 30,
                  max = lubridate::as_date(lubridate::now()) + 60),
      actionButton("reset_date_range", "Reset date range"),
      actionButton("ab_complete_date_range", "Complete date range"),
      checkboxInput("cb_complete_tasks", "Hide complete tasks"),
      numericInput("ni_font_size", "Font size", value = 4, min = 1, max = 10, step = 1)
    ),
    uiOutput("gantt.ui"),
    fluidRow(
      column(1, textInput("project_rex", label = "Filter (Project): ", value = "*")),
      column(1, textInput("section_rex", label = "Filter (Section): ", value = "*")),
      column(1, textInput("task_rex", label = "Filter (Task): ", value = "*")),
      column(1, textInput("resource_rex", label = "Filter (Resource): ", value = "*"))),
    actionButton("clear_filter", "Clear filter"),
    fluidRow(
      column(1, textInput("project_nrex", label = "Exclu (Project): ", value = "")),
      column(1, textInput("section_nrex", label = "Exclu (Section): ", value = "")),
      column(1, textInput("task_nrex", label = "Exclu (Task): ", value = "")),
      column(1, textInput("resource_nrex", label = "Exclu (Resource): ", value = ""))),
    actionButton("clear_exclu_filter", "Clear exclude filter"),
    p("Version: 0.0.0.9000", style = "font-size:9px;float:right")
  )
)
