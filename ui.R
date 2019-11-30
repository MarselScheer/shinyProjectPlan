library(shiny)

shinyUI(
  fluidPage(
    
    # Application title
    titlePanel("Gantt-chart:"),
    fileInput("file_raw_plan", label = "Upload project plan:"),
    plotOutput("gantt"),
    fluidRow(
      column(1, textInput("project_rex", label = "Filter (Project): ", value = "*")),
      column(1, textInput("section_rex", label = "Filter (Section): ", value = "*")),
      column(1, textInput("task_rex", label = "Filter (Task): ", value = "*")),
      column(1, textInput("resource_rex", label = "Filter (Resource): ", value = "*"))),
    p("Version: 0.0.0.9000", style = "font-size:9px;float:right")
  )
)
