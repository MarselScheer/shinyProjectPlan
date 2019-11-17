library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Gantt-chart:"),
  
  fileInput("file_raw_plan", label = "Upload project plan:"),
  plotOutput("gantt"),
  p("Version: 0.0.0.9000", style = "font-size:9px;float:right")
  )
)
