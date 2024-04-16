# F1 PACE: Performance Analysis and Comparison Engine

Welcome to F1 PACE. Here, I analyze lap time data sourced from the
Ergast API, focusing on the 2024 Formula One World Championship. My goal is to
examine differences in **constructor pace**, **driver lap times**, and the
**evolution of lap times** throughout each race. Through the use of
**Python** and **R** to create insightful visualizations, I plan to uncover
trends and patterns that define the thrilling dynamics of Formula One.

## Installation

To install the required libraries for both Python and R scripts, follow the
instructions provided within each script file.

### Libraries

- Pandas
- Requests
- BeautifulSoup
- Tidyverse
- Tidyquant

## Scripts

### `main_script.py`

This Python script scrapes lap time data from the Ergast API for all Grand
Prix rounds to date and stores it in a CSV file named `lap_times.csv`. It
utilizes multithreading for efficient data retrieval and includes functions
for data transformation and export.

### `report_script.R`

The R script reads lap time data from the CSV file `lap_times.csv` and
provides functions for visualizing and analyzing lap time performance. It
includes functions for comparing constructor pace, evaluating head-to-head
driver performance, and plotting the evolution of lap times throughout a
Grand Prix.

## Usage

1. Run the Python script `main_script.py` to scrape lap time data and store
   it in `lap_times.csv`.
2. Run the R script `report_script.R` to analyze the lap time data and generate
   visualizations.
3. Explore different aspects of F1 lap time performance, including
   constructor comparisons, driver head-to-head battles, and lap time evolution.