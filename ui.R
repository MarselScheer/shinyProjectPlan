library(lubridate)
library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(
    fileInput("file_raw_plan", label = "Upload project plan:"),
    sliderInput("sl_lower_date", "Lower date", 
                value = lubridate::as_date(lubridate::now()) - 30,
                min = lubridate::as_date(lubridate::now()) - 30,
                max = lubridate::as_date(lubridate::now()) + 60),
    sliderInput("sl_upper_date", "Upper date", 
                value = lubridate::as_date(lubridate::now()) + 60,
                min = lubridate::as_date(lubridate::now()) - 30,
                max = lubridate::as_date(lubridate::now()) + 60),
    actionButton("reset_date_range", "Reset date range"),
    actionButton("ab_complete_date_range", "Complete date range"),
    checkboxInput("cb_complete_tasks", "Hide complete tasks", value = TRUE),
    checkboxInput("cb_unscheduled_tasks", "Hide unscheduled tasks", value = TRUE),
    checkboxInput("cb_aborted_tasks", "Hide aborted tasks", value = TRUE),
    checkboxInput("cb_await_tasks", "Hide waiting tasks", value = TRUE),
    checkboxInput("cb_withstatus_tasks", "Keep tasks with status"),
    numericInput("ni_font_size", "Font size", value = 4, min = 1, max = 10, step = 1),
    
    textInput("anything_rex", label = "Filter (anything): ", value = "*"),
    textInput("project_rex", label = "Filter (Project): ", value = "*"),
    textInput("section_rex", label = "Filter (Section): ", value = "*"),
    textInput("task_rex", label = "Filter (Task): ", value = "*"),
    textInput("resource_rex", label = "Filter (Resource): ", value = "*"),
    actionButton("clear_filter", "Clear filter"),
    
    textInput("project_nrex", label = "Exclu (Project): ", value = ""),
    textInput("section_nrex", label = "Exclu (Section): ", value = ""),
    textInput("task_nrex", label = "Exclu (Task): ", value = ""),
    textInput("resource_nrex", label = "Exclu (Resource): ", value = ""),
    actionButton("clear_exclu_filter", "Clear exclude filter"),
    p("Version: 0.0.0.9000", style = "font-size:9px;float:right")),
  
  
  dashboardBody(
    uiOutput("gantt.ui"),
    p("Microtasks:"),
    textOutput("microtasks", container = shiny::tags$pre),
    p("Comments:"),
    textOutput("comments", container = shiny::tags$pre))
)
