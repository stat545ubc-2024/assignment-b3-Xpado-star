library(shiny)
library(DT)
library(ggplot2)
library(dplyr)
library(reshape2)

# Define the UI (User Interface)
ui <- fluidPage(
  # App title
  titlePanel("Car Data Dashboard"),
  
  # Define tabs for the app
  tabsetPanel(
    # Existing tab: Dataset Info
    tabPanel("Dataset Info",
             sidebarLayout(
               sidebarPanel(
                 h4("mtcars Dataset Abbreviations"),
                 p("Below is the explanation for each column in the dataset. This tab helps users understand the meaning of the variables used in the subsequent tabs.")
               ),
               mainPanel(
                 tableOutput("abbreviation_table")
               )
             )),
    
    # Tab: Table & Filtering
    tabPanel("Table & Filtering",
             sidebarLayout(
               sidebarPanel(
                 h4("Table & Filtering"),
                 p("Use this tab to explore and filter the dataset based on specific criteria. Adjust the sliders, checkboxes, and dropdowns to filter by MPG range, cylinder count, or transmission type. The filtered data is displayed in an interactive table, and you can download it for further use."),
                 
                 sliderInput("mpg_filter", "Filter by MPG:", 
                             min = min(mtcars$mpg), max = max(mtcars$mpg), 
                             value = c(min(mtcars$mpg), max(mtcars$mpg))),
                 p("Adjust the range of MPG values."),
                 
                 checkboxGroupInput("cyl_filter", "Filter by Cylinders:",
                                    choices = sort(unique(mtcars$cyl)), 
                                    selected = unique(mtcars$cyl)),
                 p("Select the number of cylinders you want to include."),
                 
                 selectInput("trans_filter", "Filter by Transmission:",
                             choices = c("Both" = "both", 
                                         "Automatic" = "automatic", 
                                         "Manual" = "manual"),
                             selected = "both"),
                 p("Select the transmission type to filter by."),
                 
                 downloadButton("downloadFiltered", "Download Filtered Data"),
                 p("Click to download the filtered dataset.")
               ),
               mainPanel(
                 DT::dataTableOutput("filtered_table")
               )
             )),
    
    # Tab: Scatter Plot
    tabPanel("Scatter Plot",
             sidebarLayout(
               sidebarPanel(
                 h4("Scatter Plot"),
                 p("Create a scatter plot to visualize relationships between two variables. Select the variables for the x and y axes and optionally add a trend line to observe any linear relationships."),
                 
                 selectInput("x_var", "X Variable:", choices = names(mtcars)),
                 p("Choose the variable for the x-axis."),
                 
                 selectInput("y_var", "Y Variable:", choices = names(mtcars)),
                 p("Choose the variable for the y-axis."),
                 
                 checkboxInput("show_trend", "Show Trend Line", value = FALSE),
                 p("Check to add a trend line to the plot.")
               ),
               mainPanel(
                 plotOutput("scatter_plot")
               )
             )),
    
    # Tab: Statistics
    tabPanel("Statistics",
             sidebarLayout(
               sidebarPanel(
                 h4("Statistics"),
                 p("Calculate summary statistics for a specific variable in the dataset. Choose a variable and the type of statistic (mean, median, or standard deviation) to view its value."),
                 
                 selectInput("stat_var", "Choose Variable:", choices = names(mtcars)),
                 p("Select a variable for which you want to calculate statistics."),
                 
                 radioButtons("stat_type", "Choose Statistic:", 
                              choices = c("Mean", "Median", "Standard Deviation")),
                 p("Select the type of statistic to calculate.")
               ),
               mainPanel(
                 verbatimTextOutput("stat_result")
               )
             )),
    
    # Tab: Correlation Matrix
    tabPanel("Correlation Matrix",
             sidebarLayout(
               sidebarPanel(
                 h4("Correlation Matrix"),
                 p("This tab shows a heatmap of correlations between numeric variables in the dataset. The numbers in the heatmap represent the strength and direction of the correlation:"),
                 tags$ul(
                   tags$li("-1: Perfect negative correlation (as one variable increases, the other decreases)."),
                   tags$li("0: No correlation."),
                   tags$li("1: Perfect positive correlation (as one variable increases, the other also increases).")
                 )
               ),
               mainPanel(
                 plotOutput("correlation_heatmap")
               )
             )),
    
    # Tab: Histogram
    tabPanel("Histogram",
             sidebarLayout(
               sidebarPanel(
                 h4("Histogram"),
                 p("Use this tab to visualize the distribution of a selected numeric variable. Adjust the number of bins to control the granularity of the histogram."),
                 
                 selectInput("hist_var", "Select Variable:", choices = names(mtcars)),
                 p("Select a variable to display its histogram."),
                 
                 sliderInput("bins", "Number of Bins:", min = 5, max = 50, value = 20),
                 p("Adjust the number of bins for the histogram.")
               ),
               mainPanel(
                 plotOutput("histogram_plot")
               )
             )),
    
    # Tab: Summary Statistics
    tabPanel("Summary Statistics",
             sidebarLayout(
               sidebarPanel(
                 h4("Summary Statistics"),
                 p("View key summary statistics (mean, median, minimum, maximum, and standard deviation) for all numeric variables in the filtered dataset.")
               ),
               mainPanel(
                 DT::dataTableOutput("summary_table")
               )
             ))
  )
)

# Define the server logic
server <- function(input, output, session) {
  # Feature 1: Dataset Abbreviations Table
  output$abbreviation_table <- renderTable({
    data.frame(
      Abbreviation = c("mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", 
                       "vs", "am", "gear", "carb"),
      Explanation = c("Miles/(US) gallon", "Number of cylinders", 
                      "Displacement (cu.in.)", "Gross horsepower", 
                      "Rear axle ratio", "Weight (1000 lbs)", 
                      "1/4 mile time", "Engine (0 = V-shaped, 1 = Straight)", 
                      "Transmission (0 = Automatic, 1 = Manual)", 
                      "Number of forward gears", "Number of carburetors")
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  # Feature 2: Filtered Data Table
  filtered_data <- reactive({
    data <- mtcars %>%
      filter(mpg >= input$mpg_filter[1], 
             mpg <= input$mpg_filter[2],
             cyl %in% input$cyl_filter)
    
    if (input$trans_filter != "both") {
      trans_value <- ifelse(input$trans_filter == "automatic", 0, 1)
      data <- data %>% filter(am == trans_value)
    }
    data
  })
  
  output$filtered_table <- DT::renderDataTable({
    DT::datatable(filtered_data())
  })
  
  output$downloadFiltered <- downloadHandler(
    filename = function() { paste("filtered_cars", Sys.Date(), ".csv", sep = "") },
    content = function(file) { write.csv(filtered_data(), file) }
  )
  
  # Feature 3: Scatter Plot
  output$scatter_plot <- renderPlot({
    data <- filtered_data()
    
    plot <- ggplot(data, aes_string(x = input$x_var, y = input$y_var)) +
      geom_point(color = "blue", size = 3) +
      labs(title = paste("Scatter Plot of", input$y_var, "vs", input$x_var))
    
    if (input$show_trend) {
      plot <- plot + geom_smooth(method = "lm", color = "red", se = FALSE)
    }
    plot
  })
  
  # Feature 4: Statistics Calculation
  output$stat_result <- renderPrint({
    data <- filtered_data()
    stat <- switch(input$stat_type,
                   "Mean" = mean(data[[input$stat_var]], na.rm = TRUE),
                   "Median" = median(data[[input$stat_var]], na.rm = TRUE),
                   "Standard Deviation" = sd(data[[input$stat_var]], na.rm = TRUE))
    paste("The", input$stat_type, "of", input$stat_var, "is:", round(stat, 2))
  })
  
  # New Feature 1: Correlation Heatmap
  output$correlation_heatmap <- renderPlot({
    data <- filtered_data()
    corr <- round(cor(data, use = "complete.obs"), 2)
    corr_melt <- melt(corr)
    ggplot(corr_melt, aes(x = Var1, y = Var2, fill = value)) +
      geom_tile() +
      geom_text(aes(label = value), color = "white") +
      scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
      labs(title = "Correlation Heatmap") +
      theme_minimal()
  })
  
  # New Feature 2: Histogram
  output$histogram_plot <- renderPlot({
    data <- filtered_data()
    ggplot(data, aes_string(x = input$hist_var)) +
      geom_histogram(bins = input$bins, fill = "blue", color = "black", alpha = 0.7) +
      labs(title = paste("Histogram of", input$hist_var))
  })
  
  # New Feature 3: Summary Statistics Table
  output$summary_table <- DT::renderDataTable({
    data <- filtered_data()
    stats <- data %>%
      summarise(across(where(is.numeric), 
                       list(Mean = ~mean(.),
                            Median = ~median(.),
                            Min = ~min(.),
                            Max = ~max(.),
                            StdDev = ~sd(.)), 
                       .names = "{col}_{fn}"))
    DT::datatable(t(stats))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
