library(shiny)
library(ggplot2)
library(data.table)
library(logger)
library(projectPlan)
library(dplyr)

h_wrap_comments <- function(comment) {
  comment <- unlist(strsplit(comment, "\n", fixed = TRUE))
  comment <- strwrap(comment, width = 80, exdent = 2)
  paste(comment, collapse = "\n")
}

import_plan <- function(fName, session) {
  logger::log_debug()
  if (!file.exists(fName))
    return(data.table::data.table())
  
  raw_plan <- projectPlan::import_xlsx(fName)
  preplan <- projectPlan::wrangle_raw_plan(raw_plan)
  time_lines <- projectPlan::calculate_time_lines(preplan)
  
  raw_plan <- projectPlan:::h.rd_remove_unnessary_rows(raw_plan)
  time_lines$microtasks <- raw_plan$microtasks
  time_lines$comments <- raw_plan$comments
  time_lines$comments <- sapply(time_lines$comments, h_wrap_comments)
  time_lines
  
}

filter_plan <- function(dt, input) {
  logger::log_debug()
  dt <- data.table::copy(dt)[grepl(pattern = input$project_rex, x = project)]
  dt <- dt[grepl(pattern = input$section_rex, x = section)]
  dt <- dt[grepl(pattern = input$task_rex, x = task)]
  dt <- dt[grepl(pattern = input$resource_rex, x = resource)]
  
  if (input$project_nrex != "") {
    dt <- dt[!grepl(pattern = input$project_nrex, x = project)]  
  }
  if (input$section_nrex != "") {
    dt <- dt[!grepl(pattern = input$section_nrex, x = section)]
  }
  if (input$task_nrex != "") {
    dt <- dt[!grepl(pattern = input$task_nrex, x = task)]
  }
  if (input$resource_nrex != "") {
    dt <- dt[!grepl(pattern = input$resource_nrex, x = resource)]
  }
  

  dt <- dt[input$sl_lower_date <= time_end & time_start <= input$sl_upper_date]
  
  if (input$cb_complete_tasks) {
    dt <- dt[progress != 100]  
  }
  if (input$cb_aborted_tasks) {
    dt <- dt[aborted == FALSE]
  }
  if (input$cb_await_tasks) {
    dt <- dt[waiting == FALSE]
  }
  if (input$cb_unscheduled_tasks){
    dt <- dt[unscheduled == FALSE]
  }
  if (input$cb_withstatus_tasks) {
    dt <- dt[aborted == TRUE | waiting == TRUE | unscheduled == TRUE | progress == 100]
  }
  
  dt
}

#' Initialize the logger
init_logger <- function() {
  logger::log_threshold(logger::DEBUG)
  log_layout(layout_glue_generator(format = '{node}/{pid}/{call} {time} {level}: {msg}'))
}

init_date_range <- function(session, pp) {
  logger::log_debug()
  min_date <- min(pp$time_start) - 14
  max_date <- max(pp$time_end) + 14
  updateSliderInput(session, "sl_lower_date", 
                    min = min_date, 
                    max = max_date, 
                    value = max(min_date, lubridate::as_date(lubridate::now()) - 30))
  updateSliderInput(session, "sl_upper_date", 
                    min = min_date, 
                    max = max_date, 
                    value = min(max_date, lubridate::as_date(lubridate::now()) + 60))
}

show_max_date_range <- function(session, pp) {
  logger::log_debug()
  min_date <- min(pp$time_start) - 14
  max_date <- max(pp$time_end) + 14
  updateSliderInput(session, "sl_lower_date", value = min_date)
  updateSliderInput(session, "sl_upper_date", value = max_date)
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
    init_date_range(session, data$pwr)
  })

  observeEvent(input$reset_date_range, {
    init_date_range(session, data$pwr)
  })

  observeEvent(input$ab_complete_date_range, {
    show_max_date_range(session, data$pwr)
  })
  
  observeEvent(input$clear_filter, {
    updateTextInput(session = session, inputId = "project_rex", value = "*")
    updateTextInput(session = session, inputId = "section_rex", value = "*")
    updateTextInput(session = session, inputId = "task_rex", value = "*")
    updateTextInput(session = session, inputId = "resource_rex", value = "*")
  })
  observeEvent(input$clear_exclu_filter, {
    updateTextInput(session = session, inputId = "project_nrex", value = "")
    updateTextInput(session = session, inputId = "section_nrex", value = "")
    updateTextInput(session = session, inputId = "task_nrex", value = "")
    updateTextInput(session = session, inputId = "resource_nrex", value = "")
  })

  observeEvent(
    eventExpr = input$gantt_click,
    handlerExpr = {
      idx <- round(input$gantt_click$y)
      filter_dt <- filter_plan(data$pwr, input)
      idx <- rev(1:nrow(filter_dt))[idx]
      sub <- filter_dt[idx]
      output$microtasks <- renderText({sub$microtasks})
      output$comments <- renderText({sub$comments})
    },
    ignoreInit = FALSE, ignoreNULL = TRUE
  )
  
    
  output$gantt.ui <- renderUI({
    logger::log_debug()
    dt <- data$pwr
    if (is.null(dt)) {
      N <- 5
    } else {
      N <- nrow(filter_plan(dt, input))
    }
    plotOutput("gantt", height = 100 + N * 25, click = "gantt_click")
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
    
    projectPlan::gantt_by_sections(
      dt, 
      show_dependencies = TRUE, 
      text_size = input$ni_font_size,
      xlim = c(input$sl_lower_date, input$sl_upper_date))    
  })
})
