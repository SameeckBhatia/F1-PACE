# F1 PACE: Performance Analysis and Comparison Engine

Welcome to F1 PACE. Here, I analyze lap time data sourced from the
Ergast API, focusing on the 2024 Formula One World Championship. My goal is to
examine differences in constructor pace, driver lap times, and the
evolution of lap times throughout each race. Through the use of
Python and R to create insightful visualizations, I plan to uncover
trends and patterns that define the thrilling dynamics of Formula One.

## File Structure

The repo is structured as:

- `data` contains all datasets relevant to the analysis.
- `plots` contains generated plots for different GP races.
- `requirements` contains the necessary dependencies for the project.
- `main_script.py` is the Python script responsible for data collection and cleaning.
- `report_script.R` is the R script used to create visualizations.
- `report.pdf` contains a final report for a specific GP race.

## Usage

1. Run the Python script `main_script.py` to scrape lap time data and store
   it in `data/lap_times.csv`.
2. Run the R script `report_script.R` to analyze the lap time data and generate
   visualizations found in `plots`.
3. Explore different aspects of F1 lap time performance, including
   constructor comparisons, driver head-to-head battles, and lap time evolution.
