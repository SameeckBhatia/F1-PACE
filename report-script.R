# Uncomment the below line to install libraries
# install.packages(c("tidyverse", "tidyquant"))

library(tidyverse)
library(tidyquant)

lap_times <- read.csv("python/lap_times.csv")

constructor_colors <- list(
  "Alpine" = "#FF87BC", "Aston Martin" = "#229971", "Ferrari" = "#E8002D",
  "Haas" = "#B6BABD", "Kick Sauber" = "#52E252", "McLaren" = "#FF8000",
  "Mercedes" = "#27F4D2", "Racing Bulls" = "#6692FF", "Red Bull" = "#3671C6",
  "Williams" = "#64C4FF"
)

driver_colors <- list(
  "VER" = "#3671C6", "PER" = "#204374", "SAI" = "#E8002D", "LEC" = "#800019",
  "RUS" = "#27F4D2", "NOR" = "#FF8000", "HAM" = "#09aa8f", "PIA" = "#994c00",
  "ALO" = "#229971", "STR" = "#104735"
)
