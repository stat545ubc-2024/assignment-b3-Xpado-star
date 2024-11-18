library(shiny)
library(DT)
library(ggplot2)
library(dplyr)

# Define the UI (User Interface)
ui <- fluidPage(
  # App title
  titlePanel("Car Data Dashboard"),
  
  # Define tabs for the app
  tabsetPanel(
    # Tab 1: Dataset Information and explaining the abbreviations used in the mtcars dataset
    tabPanel("Dataset Info",
             sidebarLayout(
               sidebarPanel(
                 # Informational text
                 h4("mtcars Dataset Abbreviations"),
                 p("Below is the explanation for each column in the dataset:")
               ),
               mainPanel(
                 # Table to display abbreviations and explanations
                 tableOutput("abbreviation_table")
               )
             )),
    
    # Tab 2: Table & Filtering Feature
    tabPanel("Table & Filtering",
             sidebarLayout(
               sidebarPanel(
                 # Slider to filter by MPG range
                 sliderInput("mpg_filter", "Filter by MPG:", 
                             min = min(mtcars$mpg), max = max(mtcars$mpg), 
                             value = c(min(mtcars$mpg), max(mtcars$mpg))),
                 
                 # Checkboxes to filter by number of cylinders
                 checkboxGroupInput("cyl_filter", "Filter by Cylinders:",
                                    choices = sort(unique(mtcars$cyl)), 
                                    selected = unique(mtcars$cyl)),
                 
                 # Dropdown to filter by transmission type
                 selectInput("trans_filter", "Filter by Transmission:",
                             choices = c("Both" = "both", 
                                         "Automatic" = "automatic", 
                                         "Manual" = "manual"),
                             selected = "both"),
                 
                 # Button to download the filtered data as a CSV file
                 downloadButton("downloadFiltered", "Download Filtered Data")
               ),
               mainPanel(
                 # Interactive table to display filtered data
                 DT::dataTableOutput("filtered_table")
               )
             )),
    
    # Tab 3: Plotting Feature
    tabPanel("Scatter Plot",
             sidebarLayout(
               sidebarPanel(
                 # Dropdowns to select x and y variables for scatter plot
                 selectInput("x_var", "X Variable:", choices = names(mtcars)),
                 selectInput("y_var", "Y Variable:", choices = names(mtcars)),
                 
                 # Checkbox to add a trend line
                 checkboxInput("show_trend", "Show Trend Line", value = FALSE)
               ),
               mainPanel(
                 # Output area for the scatter plot
                 plotOutput("scatter_plot")
               )
             )),
    
    # Tab 4: Statistics Feature
    tabPanel("Statistics",
             sidebarLayout(
               sidebarPanel(
                 # Dropdown to select a variable for statistics
                 selectInput("stat_var", "Choose Variable:", choices = names(mtcars)),
                 
                 # Radio buttons to select the type of statistic
                 radioButtons("stat_type", "Choose Statistic:", 
                              choices = c("Mean", "Median", "Standard Deviation"))
               ),
               mainPanel(
                 # Output area for the calculated statistic
                 verbatimTextOutput("stat_result")
               )
             ))
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Feature 1: Dataset Abbreviations Table
  # This is the first feature and is very useful for explaining certain abbreviations as they can be very confusing: e.g. drat - rear axle ratio.
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
  # This feature allows users to filter cars by their cylinder as well as transmission.
  # Furthermore, the users can use an interactive slider to filter based on miles/gallon which is a prime factor when choosing efficient cars.
  # The table also has additional useful capabilities such as filtering from highest value to lowest for all the variables.
  # Lastly, the user can also download the table as a CSV file.
  filtered_data <- reactive({
    data <- mtcars %>%
      filter(mpg >= input$mpg_filter[1],  # Filter by MPG range
             mpg <= input$mpg_filter[2],
             cyl %in% input$cyl_filter)   # Filter by selected cylinders
    
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
  # This tab enables users to create scatter plots between any two variables in the dataset. 
  # Additionally, users can also add an optional trend line to visualize potential correlations.
  # This feature enhances data visualization by allowing users to explore relationships between variables. The trend line option further supports hypothesis generation and deeper insights, making it valuable for quick exploratory analysis.
  output$scatter_plot <- renderPlot({
    data <- filtered_data()
    
    ggplot(data, aes_string(x = input$x_var, y = input$y_var)) +
      geom_point(color = "blue", size = 3) +
      labs(title = paste("Scatter Plot of", input$y_var, "vs", input$x_var)) +
      if (input$show_trend) {
        geom_smooth(method = "lm", color = "red", se = FALSE)
      }
  })
  
  # Feature 4: Statistics Calculation
  # Building on the third tab, The "Statistics" tab allows users to calculate the mean, median, or standard deviation of a chosen variable from the dataset. 
  # Users can select the variable and the type of statistic through dropdowns and radio buttons.
  # This feature provides a quick summary of key statistical properties for any variable in the dataset. It is especially useful for users looking to perform basic exploratory data analysis without requiring external tools or software, helping them gain immediate insights into the data.
  output$stat_result <- renderPrint({
    data <- filtered_data()
    stat <- switch(input$stat_type,
                   "Mean" = mean(data[[input$stat_var]], na.rm = TRUE),
                   "Median" = median(data[[input$stat_var]], na.rm = TRUE),
                   "Standard Deviation" = sd(data[[input$stat_var]], na.rm = TRUE))
    paste("The", input$stat_type, "of", input$stat_var, "is:", round(stat, 2))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
