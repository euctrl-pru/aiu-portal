library(dplyr)
library(ggplot2)
library(viridis)
library(lubridate)
library(scales)
library(sitools)

source("R/read_ert_dly.R")

# round average daily number of flights to the nearest ten (-1 in round()).
ectrl_ert_flt_yyyy <- ectrl_summaries %>%
  group_by(yyyy) %>%
  summarise(days = n(), flt_avg = round(sum(flights) / days, -1)) %>%
  mutate(date = ymd(str_c(yyyy,"-01-01")))

g <- ggplot(ectrl_ert_flt_yyyy, aes(x = as.Date(date), y = flt_avg))

ert_flt_yyyy_plot <- g +
  geom_line() +
  geom_point() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y", minor_breaks = NULL) +
  coord_cartesian(ylim = c(20000, 30000)) +
  scale_y_continuous(labels = f2si) +
  theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
  labs(
    x = "Year",
    y = "Daily average number of flight",
    title = "Daily average number of flights in EUROCONTROL Area",
    subtitle = "Rounded to the nearest ten.")

ggsave("_assets/images/ert_flt_yyy.png", plot = ert_flt_yyyy_plot)



g <- ggplot(data = ectrl_summaries, aes(x = as.Date(date), y = flights))

ert_dly_dd_plot <- g +
  geom_smooth(data = ectrl_summaries, aes(x = as.Date(date), y = flights), show.legend = TRUE) +
  coord_cartesian(ylim = c(20000, 30000)) +
  scale_y_continuous(labels = f2si) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y", minor_breaks = NULL) +
  labs(
    x = "Year",
    y = "Daily number of flight",
    title = "Daily number of flights in EUROCONTROL Area",
    subtitle = "Soothed with linear model.")

ggsave("_assets/images/ert_dly_dd_smooth.png", plot = ert_dly_dd_plot)



# library(plotly)
# ggplotly(plot)
