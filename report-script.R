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

outliers <- function(df, col) {
  q1 <- quantile(df[[col]], 0.25)
  q3 <- quantile(df[[col]], 0.75)
  iqr <- q3 - q1

  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr

  df %>% filter(lower < df[[col]], df[[col]] < upper)

}

plot_1 <- function(gp) {
  png(width = 1000, height = 750, units = "px", res = 240,
      filename = paste0("plots/", gp, "_compare.png"))
  plot(lap_times %>%
         filter(grand_prix == gp) %>%
         outliers(col = "time") %>%
         group_by(constructor) %>%
         summarise(med = median(time)) %>%
         mutate(delta = med - min(med)) %>%
         ggplot(aes(x = reorder(constructor, desc(med)), y = delta)) +
         geom_col(aes(fill = constructor_colors[constructor]), color = "black") +
         labs(x = "Constructor", y = "Delta to Fastest (sec)") +
         coord_flip())
  dev.off()
}
