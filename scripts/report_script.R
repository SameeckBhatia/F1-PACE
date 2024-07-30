# Uncomment the below line to install libraries
# install.packages(c("tidyverse", "tidyquant"))

library(tidyverse)
library(tidyquant)

# Reading the data
lap_times <- read.csv("lap_times.csv")

# Color list
constructor_colors <- list(
  "Alpine" = "#FF87BC", "Aston Martin" = "#229971", "Ferrari" = "#E8002D",
  "Haas" = "#B6BABD", "Kick Sauber" = "#52E252", "McLaren" = "#FF8000",
  "Mercedes" = "#27F4D2", "Racing Bulls" = "#6692FF", "Red Bull" = "#3671C6",
  "Williams" = "#64C4FF"
)

# Color list
driver_colors <- list(
  "VER" = "#3671C6", "PER" = "#204374", "LEC" = "#E8002D", "SAI" = "#800019",
  "BEA" = "#800019", "RUS" = "#27F4D2", "HAM" = "#09AA8F", "NOR" = "#FF8000",
  "PIA" = "#994C00", "ALO" = "#229971", "STR" = "#104735", "RIC" = "#6692FF",
  "TSU" = "#5274CC", "HUL" = "#B6BABD", "MAG" = "#81888D"
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
      filename = paste0("plots/", gsub(" ", "_", gp), "_compare.png"))
  # Plotting the data
  plot(lap_times %>%
         filter(grand_prix == gp) %>%
         outliers(col = "time") %>%
         group_by(lap, constructor) %>%
         summarise(min = min(time)) %>%
         group_by(constructor) %>%
         summarise(med = median(min)) %>%
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
      filename = paste0("plots/", gsub(" ", "_", gp), "_h2h.png"))
  # Plotting the data
  plot(lap_times %>%
         filter(grand_prix == gp, driver %in% c(driver1, driver2)) %>%
         select(driver, lap, time) %>%
         arrange(lap) %>%
         pivot_wider(names_from = driver, values_from = time) %>%
         mutate(delta = cumsum(!!sym(driver1) - !!sym(driver2))) %>%
         ggplot(aes(x = lap, y = delta, fill = driver_colors[driver1])) +
         geom_col(width = 1) +
         labs(x = "Lap", y = paste(driver1, "Gap to", driver2, "(sec behind)")))
  dev.off()
}

# Lap time evolution function
plot_3 <- function(gp, color) {
  # Setting up the png device
  png(width = 1000, height = 750, units = "px", res = 240,
      filename = paste0("plots/", gsub(" ", "_", gp), "_evo.png"))
  # Plotting the data
  plot(lap_times %>%
         filter(grand_prix == gp, lap != 1) %>%
         outliers(col = "time") %>%
         arrange(lap) %>%
         group_by(lap) %>%
         summarise(min = min(time)) %>%
         ggplot(aes(x = lap, y = min)) +
         geom_smooth(color = color, span = 1 / 5, linewidth = 0.5) +
         labs(x = "Lap", y = "Minimum Time (sec)"))
  dev.off()
}

# Wrapper function
plot_all <- function(gp, driver1, driver2, color) {
  plot_1(gp)
  plot_2(gp, driver1, driver2)
  plot_3(gp, color)
}

# Bahrain GP
plot_all("Bahrain", "RIC", "TSU", "#DA291C")

# Saudi GP
plot_all("Saudi Arabia", "BEA", "NOR", "#005430")

# Australian GP
plot_all("Australia", "LEC", "SAI", "#00008B")

# Japanese GP
plot_all("Japan", "ALO", "RUS", "#B0000F")

# Chinese GP
plot_all("China", "ALO", "HAM", "#EE1C25")

# Miami GP
plot_all("Miami", "NOR", "VER", "#00A8CC")

# Emilia Romagna GP
plot_all("Emilia Romagna", "NOR", "VER", "#009B47")

# Monaco GP
plot_all("Monaco", "LEC", "PIA", "#CF0921")

# Canadian GP
plot_all("Canada", "HAM", "RUS", "#D80621")

# Spanish GP
plot_all("Spain", "LEC", "RUS", "#FABD00")

# Austrian GP
plot_all("Austria", "NOR", "VER", "#C8102E")

# British GP
plot_all("Great Britain", "HAM", "VER", "#012169")

# Hungarian GP
plot_all("Hungary", "NOR", "PIA", "#477050")

# Belgian GP
plot_all("Belgium", "RUS", "HAM", "#EF3340")