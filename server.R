library(shiny)
library(ggplot2)
library(data.table)
library(logger)
library(projectPlan)

import_plan <- function(fName, session) {
  logger::log_debug()
  if (!file.exists(fName))
    return(data.table::data.table())
  
  raw_plan <- projectPlan::import_xlsx(fName)
  preplan <- projectPlan::wrangle_raw_plan(raw_plan)
  projectPlan::calculate_time_lines(preplan)
  
}

filter_plan <- function(dt, input) {
  dt <- data.table::copy(dt)[grepl(pattern = input$project_rex, x = project)]
  dt <- dt[grepl(pattern = input$section_rex, x = section)]
  dt <- dt[grepl(pattern = input$task_rex, x = task)]
  dt <- dt[grepl(pattern = input$resource_rex, x = resource)]
  dt <- dt[input$gantt_date_range[1] < time_start & time_end < input$gantt_date_range[2]]
  dt
}

#' Initialize the logger
init_logger <- function() {
  logger::log_threshold(logger::DEBUG)
  log_layout(layout_glue_generator(format = '{node}/{pid}/{call} {time} {level}: {msg}'))
}

shinyServer(function(input, output, session) {

  init_logger()
  logger::log_debug()
  
  data <- reactiveValues(pwr = NULL)
  
  observeEvent(input$file_raw_plan, {
    # clicking upload
    inFile <- input$file_raw_plan
    
    if (is.null(inFile))
      return(NULL)
    
    data$pwr <- import_plan(inFile$datapath, session)
    min_date <- min(data$pwr$time_start) - 14
    max_date <- max(data$pwr$time_end) + 14
    updateDateRangeInput(session, "gantt_date_range", 
                      min = min_date,
                      max = max_date,
                      start = max(min_date, lubridate::as_date(lubridate::now()) - 7),
                      end = min(max_date, lubridate::as_date(lubridate::now()) + 14))
    
  })
  
  observeEvent(input$clear_filter, {
    updateTextInput(session = session, inputId = "project_rex", value = "*")
    updateTextInput(session = session, inputId = "section_rex", value = "*")
    updateTextInput(session = session, inputId = "task_rex", value = "*")
    updateTextInput(session = session, inputId = "resource_rex", value = "*")
  })
  
  output$gantt.ui <- renderUI({
    dt <- data$pwr
    if (is.null(dt)) {
      N <- 5
    } else {
      N <- nrow(dt)
    }
    plotOutput("gantt", height = N * 15)
  })
  
  output$gantt <- renderPlot({
    logger::log_debug()

    dt <- data.table::copy(data$pwr)
    if (is.null(dt)) {
       return(ggplot())
    }
    
    dt <- filter_plan(dt, input)
    if (nrow(dt) == 0) {
      return(ggplot())
    }
    
    projectPlan::gantt_by_sections(dt)    
  })
})
