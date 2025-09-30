# Define server logic to read selected file ----
server <- function(input, output) {
  detected_sep <- reactiveValues(value = NULL)
  detected_dec <- reactiveValues(value = NULL)
  miss_obj <- reactiveValues(df = NULL)
  imputed_obj <- reactiveValues(df = NULL)
  disable("ImputeOn")
  disable("download_data")



  # 1. upload file
  observeEvent(input$file, {
    disable("ImputeOn")
    disable("download_data")
    lines <- readLines(input$file$datapath, n = 5)
    # I. detect separator
    sep_candidates <- c("," = ",",
                        ";" = ";",
                        "\t" = "\t")

    counts <- sapply(sep_candidates, function(sep) {
      mean(sapply(lines, function(line) length(strsplit(line, sep)[[1]])))
    })
    detected_sep$value <- sep_candidates[which.max(counts)]

    # II. detect decimal
    dots <- sum(grepl("\\d+\\.\\d+", lines))   # numbers with dot
    commas <- sum(grepl("\\d+,\\d+", lines))   # numbers with comma

    if (dots > commas) {
      detected_dec$value <- "."
    } else if (commas > dots) {
      detected_dec$value <- ","
    } else {
      detected_dec$value <- "."  # default
    }
  })





  # 2. sanity check
  observeEvent(input$file, {
    missMat <- read.csv(input$file$datapath,
                        sep = detected_sep$value,
                        dec = detected_dec$value,
                        row.names = 1)
    n = 0
    if (nrow(missMat) > 10000 | ncol(missMat) > 50){
      output$data_status1 <- renderText({"⚠️ Data is too big!"})
      n = 1
    }
    if (any(rowSums(!is.na(missMat)) == 0)){
      output$data_status2 <- renderText({"⚠️ The completely missing proteins in the data have been filtered out."})
      missMat <- missMat[rowSums(!is.na(missMat)) > 0, ]
    }
    if (n == 0) {
      miss_obj$df <- missMat
      enable("ImputeOn")
      output$data_status1 <- NULL
      output$data_status2 <- NULL
    }
  })

  # # test
  # output$value <- renderText({
  #   input$num
  # })



  # 3.1 table 1: initial data
  output$initial <- renderDataTable({
    req(miss_obj$df)
    showMissMat <- datatable(round(miss_obj$df, 2),
                             extensions = "FixedColumns",
                             options = list(dom = 'Bfrtip', scrollX = TRUE, fixedColumns = TRUE))
    formatStyle(table = showMissMat, colnames(miss_obj$df)[1:ncol(miss_obj$df)],
                backgroundColor = styleEqual(NA , '#ffc8c8'))
    })


  # 3.2 plot distribution and missing pattern of data
  output$distPlot <- renderPlot({
    req(miss_obj$df)

    p1 <- miss_obj$df %>%
      rownames_to_column("protID") %>%
      pivot_longer(-protID, names_to = "smpID", values_to = "abundance") %>%
      ggplot(aes(x = abundance)) +
      geom_density(fill = "lightgray") +
      theme_classic() +
      theme(axis.text = element_text(size = 18),
            axis.title = element_text(size = 18, face = "bold"),
            plot.title = element_text(size = 18, face = "bold", hjust = 0.5)) +
      labs(title = "Distribution")

    p2 <- miss_obj$df %>%
      tibble(abundance = rowMeans(., na.rm = TRUE),
             `missing rate` = rowSums(is.na(.))/ncol(.)) %>%
        ggplot(aes(x = abundance, y = `missing rate`)) +
        geom_point(color = "lightblue") +
        theme_classic() +
        theme(axis.text = element_text(size = 18),
              axis.title = element_text(size = 18, face = "bold"),
              plot.title = element_text(size = 18, face = "bold", hjust = 0.5)) +
      ggtitle("Missing Pattern")

    cowplot::plot_grid(p1, NULL, p2, rel_widths = c(1, 0.25, 1), nrow = 1)
  })





  # 4 impute
  observeEvent(input$advanced, {
    disable("download_data")
  })

  observeEvent(input$ImputeOn, {
    req(miss_obj$df)
    showPageSpinner(caption = HTML("<div style='text-align:center'>
    <span style='font-size:24px;'>The model is running......</span><br/>
    <span style='font-size:18px;'>(approximately 1 minute)</span>
                                   </div>"))
    if (input$num <= 0) n_components <- NULL else n_components <- input$num
    res <- runMsBayesImpute(miss_obj$df,
                            n_components = n_components,
                            drop_factor_threshold = input$threshold/100,
                            convergence_mode = input$mode)
    hidePageSpinner()
    imputed_obj$df <- res$data
    enable("download_data")
  })





  # 5. table 2: imputed data
  output$imputed <- renderDataTable({
    req(imputed_obj$df)

    showImputeMat <- datatable(round(imputed_obj$df, 2),
                               # caption = "Table 2: Initial data after msBayesImpute imputation",
                               extensions = "FixedColumns",
                               options = list(dom = 'Bfrtip', scrollX = TRUE, fixedColumns = TRUE))
    formatStyle(table = showImputeMat, colnames(imputed_obj$df)[1:ncol(imputed_obj$df)],
                backgroundColor = styleEqual(NA , '#ffc8c8'))
  })


  # download imputed data
  output$download_data <- downloadHandler(
    filename = paste0("imputed_data_", Sys.Date(), ".csv"),
    content = function(file) {
      write.csv(imputed_obj$df, file)
      req(imputed_obj$df)  # ensure data exists before downloading
    }
  )
  }




