library(shiny)
library(DT)
library(shinyjs)
library(shinycssloaders)
library(shinyWidgets)
library(msBayesImpute)
library(ggplot2)
library(tidyverse)

ui <- fluidPage(
  useShinyjs(),
  titlePanel(
    HTML("
    <span style='font-size:24px;'>msBayesImpute</span><br/>
    <span style='font-size:18px;color: gray'>A Versatile Framework for Addressing Missing Values
    in Biomedical Mass Spectrometry Proteomics Data</span>
                                   </div>")),
  sidebarLayout(
    sidebarPanel(
      div("Introduction", style = "font-size:14px; font-weight: bold"),
      helpText(
        "- Input a data matrix with proteins on rows and samples on columns.
        The first column should be protein IDs and the first row should be sample IDs.
        The size limite is:",
        br(),
        "1. protein size <= 10,000",
        br(),
        "2. sample size <= 100",
        br(), br(),
        "- The prerequisite of data prior to imputation is:",
        br(),
        "1. normally distributed using, e.g., log transformation of orginial values",
        br(),
        "2. remove completely missing proteins",
        br(),br(),
      ),

      fileInput("file",
                "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      textOutput("data_status1"),
      textOutput("data_status2"),
      tags$hr(),

      # # Input: Checkbox if file has header ----
      # checkboxInput("header", "Header", TRUE),

      # # Input: Select separator ----
      # radioButtons("sep", "Separator",
      #              choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
      #              selected = "\t"),

      # div(
      #   style = "display: flex; align-items: center; gap: 5px;",
      #   dropdown(
      #     label = "option",
      #     icon = icon("gear"),
      #     numericInput("num", "The number of components", value = -1, width = "250px"),
      #     numericInput("threshold", "Explained variance threshold (%)", value = 1),
      #     selectInput("mode", "Running mode", choices = c("fast", "slow")),
      #     circle = FALSE,   # optional styling
      #     status = "primary"),
      #   actionButton("ImputeOn", "Impute!", style = "font-weight: bold; font-size: 15px;"),
      # ),
      actionButton("ImputeOn", "Impute!", style = "font-weight: bold; font-size: 15px;"),
      checkboxInput(inputId = "advanced",
                    label = "Advanced",
                    value = FALSE),
      conditionalPanel(condition = "input.advanced",
                       numericInput("num", "The number of components", value = -1, width = "250px"),
                       numericInput("threshold", "Explained variance threshold (%)", value = 1),
                       selectInput("mode", "Running mode", choices = c("fast", "slow")),
                       p("Note: The model prioritizes the number of components;
                         if the number <= 0, the model will automatically find significant components above the explained variance threshold.")),

      tags$hr(),
      downloadButton("download_data", "Download Data")
      ),






    # Main panel for displaying outputs ----
    mainPanel(
      tags$div(style = "text-align: center; font-weight: bold; font-size: 20px; margin-bottom: 5px;",
                          "Table 1: Initial data with missing values"),
      dataTableOutput("initial"),

      br(),br(),

      tags$div(style = "text-align: center; font-weight: bold; font-size: 20px; margin-bottom: 5px;",
               "Visualising initial data with missing values"),
      br(),
      plotOutput(outputId = "distPlot"),

      br(),
      tags$hr(),
      br(),

      tags$div(style = "text-align: center; font-weight: bold; font-size: 20px; margin-bottom: 5px;",
                          "Table 2: Imputed data using  msBayesImpute"),
      dataTableOutput("imputed"),

      br(),

      textOutput("value")
    )
  )
)

