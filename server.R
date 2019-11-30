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
  })
  
  output$gantt <- renderPlot({
    logger::log_debug()

    dt <- data.table::copy(data$pwr)
    if (is.null(dt)) {
       return(ggplot())
    }
    
    dt <- dt[grepl(pattern = input$project_rex, x = project)]
    dt <- dt[grepl(pattern = input$section_rex, x = section)]
    dt <- dt[grepl(pattern = input$task_rex, x = task)]
    dt <- dt[grepl(pattern = input$resource_rex, x = resource)]
    if (nrow(dt) == 0) {
      return(ggplot())
    }
    
    projectPlan::gantt_by_sections(dt)    
  })
})
