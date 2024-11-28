# **Explore mtcars Dataset - Shiny App**

## **Link to Running Instance of the Shiny App:**

[**V1: Explore mtcars Dataset**](https://dtan16.shinyapps.io/assignment-b3-xpado-star/)

[**V2: Explore mtcars Dataset**](https://dtan16.shinyapps.io/assignmentb4/)

---

## **Description of the App:**

This Shiny app provides an interactive interface for exploring the **mtcars** dataset, a classic dataset from R. The app has been enhanced with several new features and interactive options, designed to facilitate more dynamic data exploration:

1. **Dataset Information**: This tab explains the abbreviations used in the dataset (e.g., "mpg" stands for miles per gallon, and "hp" stands for horsepower), helping users understand the context of the data.

2. **Table & Filtering**: Users can filter the dataset based on various parameters (e.g., MPG, cylinders, and transmission type). The filtered dataset is displayed in an interactive table, and users can download it as a CSV file for offline analysis. Additionally, there are now clearer explanations for each filter, making it easier to use.

3. **Scatter Plot**: This feature allows users to create scatter plots between any two variables in the dataset. Users can also choose to add a trend line to visualize potential correlations between the selected variables.

4. **Statistics Calculation**: Users can calculate basic statistics (mean, median, and standard deviation) for any selected variable in the dataset. The calculated statistic is displayed dynamically based on user input.

5. **New Feature 1: Correlation Matrix**: This new feature shows a heatmap of correlations between numeric variables in the dataset, helping users identify potential relationships. The heatmap includes color coding to indicate the strength and direction of correlations (from -1 to 1).

6. **New Feature 2: Histogram**: Users can now create histograms for any numeric variable in the dataset. The histogram’s granularity can be adjusted by changing the number of bins, giving users flexibility in how the distribution is visualized.

7. **New Feature 3: Summary Statistics**: This new feature calculates and displays summary statistics (mean, median, minimum, maximum, and standard deviation) for all numeric variables in the filtered dataset, presented in an easy-to-read table.

---

## **Dataset Acknowledgement:**

The **mtcars** dataset is built into R and can be accessed directly through RStudio by running:

```r
data(mtcars)
