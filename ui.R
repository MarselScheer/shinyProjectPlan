library(lubridate)
library(shiny)

shinyUI(
  fluidPage(
    # Application title
    titlePanel("Gantt-chart:"),
    fluidRow(
      column(3, fileInput("file_raw_plan", label = "Upload project plan:")),
      column(3, dateRangeInput("gantt_date_range", "Date range:",
                               start  = "2001-01-01",
                               end    = "2010-12-31",
                               min    = "2001-01-01",
                               max    = "2012-12-21",
                               format = "yyyy-mm-dd",
                               separator = " - ")),
      actionButton("reset_date_range", "Reset date range")
    ),
    uiOutput("gantt.ui"),
    fluidRow(
      column(1, textInput("project_rex", label = "Filter (Project): ", value = "*")),
      column(1, textInput("section_rex", label = "Filter (Section): ", value = "*")),
      column(1, textInput("task_rex", label = "Filter (Task): ", value = "*")),
      column(1, textInput("resource_rex", label = "Filter (Resource): ", value = "*"))),
    actionButton("clear_filter", "Clear filter"),
    p("Version: 0.0.0.9000", style = "font-size:9px;float:right")
  )
)
