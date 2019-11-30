library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Gantt-chart:"),
  
  fileInput("file_raw_plan", label = "Upload project plan:"),
  #numericInput(inputId = "gantt_height", label = "Height of the Gantt-chart", value = 400, step = 100),
  uiOutput("gantt.ui"),
  p("Version: 0.0.0.9000", style = "font-size:9px;float:right")
  )
)
