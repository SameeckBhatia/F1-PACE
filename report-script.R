# Uncomment the below line to install libraries
# install.packages(c("tidyverse", "tidyquant"))

library(tidyverse)
library(tidyquant)

# Reading the data
lap_times <- read.csv("python/lap_times.csv")

# Color list
constructor_colors <- list(
  "Alpine" = "#FF87BC", "Aston Martin" = "#229971", "Ferrari" = "#E8002D",
  "Haas" = "#B6BABD", "Kick Sauber" = "#52E252", "McLaren" = "#FF8000",
  "Mercedes" = "#27F4D2", "Racing Bulls" = "#6692FF", "Red Bull" = "#3671C6",
  "Williams" = "#64C4FF"
)

# Color list
driver_colors <- list(
  "VER" = "#3671C6", "PER" = "#204374", "SAI" = "#E8002D", "LEC" = "#800019",
  "RUS" = "#27F4D2", "NOR" = "#FF8000", "HAM" = "#09aa8f", "PIA" = "#994c00",
  "ALO" = "#229971", "STR" = "#104735", "RIC" = "#6692FF", "TSU" = "#5274cc"
)

# Outlier function
outliers <- function(df, col) {
  q1 <- quantile(df[[col]], 0.25)
  q3 <- quantile(df[[col]], 0.75)
  iqr <- q3 - q1

  upper <- q3 + 1.5 * iqr

  df %>% filter(df[[col]] < upper)

}

# Constructor pace function
plot_1 <- function(gp) {
  # Setting up the png device
  png(width = 1000, height = 750, units = "px", res = 240,
      filename = paste0("plots/", gp, "_compare.png"))
  # Plotting the data
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

# Driver pace function
plot_2 <- function(gp, driver1, driver2) {
  # Setting up the png device
  png(width = 1000, height = 750, units = "px", res = 240,
      filename = paste0("plots/", gp, "_h2h.png"))
  # Plotting the data
  plot(lap_times %>%
         filter(driver %in% c(driver1, driver2)) %>%
         select(driver, lap, time) %>%
         arrange(lap) %>%
         pivot_wider(names_from = driver, values_from = time) %>%
         mutate(delta = cumsum(!!sym(driver1) - !!sym(driver2))) %>%
         ggplot(aes(x = lap, y = delta, fill = driver_colors[driver1])) +
         stat_smooth(geom = "area", span = 1 / 4) +
         labs(x = "Lap", y = paste(driver1, "Gap to", driver2, "(sec behind)")))
  dev.off()
}

# Lap time evolution function
plot_3 <- function(gp, color) {
  # Setting up the png device
  png(width = 1000, height = 750, units = "px", res = 240,
      filename = paste0("plots/", gp, "_lrf.png"))
  # Plotting the data
  plot(lap_times %>%
         filter(grand_prix == gp, lap != 1) %>%
         arrange(lap) %>%
         group_by(lap) %>%
         summarise(med = median(time)) %>%
         ggplot(aes(x = lap, y = med)) +
         geom_line(color = "black") +
         geom_smooth(method = "lm", se = FALSE, color = color) +
         labs(x = "Lap", y = "Median Time (sec)"))
  dev.off()
}

# Wrapper function
plot_all <- function(gp, driver1, driver2, color) {
  plot_1(gp)
  plot_2(gp, driver1, driver2)
  plot_3(gp, color)
}

# Bahrain GP
plot_all("Bahrain", "TSU", "RIC", "#DA291C")
