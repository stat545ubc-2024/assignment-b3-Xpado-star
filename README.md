## **Link to Running Instance of the Shiny App:**

[**Explore mtcars Dataset**](https://dtan16.shinyapps.io/assignment-b3-xpado-star/)

---

## **Description of the App:**

This Shiny app provides an interactive interface for exploring the **mtcars** dataset, a classic dataset from R. The app includes several features designed to enhance data exploration:

1. **Dataset Information**: This tab explains the abbreviations used in the dataset (e.g., "mpg" stands for miles per gallon, and "hp" stands for horsepower), helping users understand the context of the data.

2. **Table & Filtering**: Users can filter the dataset based on various parameters (e.g., MPG, cylinders, and transmission type) and download the filtered data as a CSV file for offline analysis.

3. **Scatter Plot**: This feature allows users to create scatter plots between any two variables in the dataset. It also includes an option to add a trend line to visualize potential correlations.

4. **Statistics Calculation**: Users can calculate basic statistics (mean, median, and standard deviation) for any variable in the dataset, enabling quick exploratory analysis.

---

## **Dataset Acknowledgement:**

The **mtcars** dataset is built into R and can be accessed directly through RStudio by running:

```r
data(mtcars)
