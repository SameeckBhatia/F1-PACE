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
