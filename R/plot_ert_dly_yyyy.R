library(dplyr)
library(ggplot2)
library(viridis)

source("R/read_ert_dly.R")

ectrl_details_yyyy <- ectrl_details %>%
  group_by(yyyy, delay_group) %>%
  summarise(delay = sum(delay))

ectrl_summaries_yyyy <- ectrl_summaries %>%
  group_by(yyyy) %>%
  summarise(flt_tot = sum(flights), flt_dly = sum(flights_delayed), flt_dly_gt15 = sum(flights_delayed_gt15))


ectrl_yyyy <- inner_join(ectrl_details_yyyy, ectrl_summaries_yyyy, by = "yyyy")


g <- ggplot(ectrl_yyyy, aes(x = yyyy, y = delay/flt_tot, fill = delay_group))

ert_dly_yyyy_plot <- g +
  geom_bar(stat = "identity") +
  # scale_x_date(
  #   date_labels = "%Y",
  #   date_breaks = "1 year") +
  scale_x_continuous(breaks = seq(2008,2017,1)) +
  scale_fill_viridis(discrete = TRUE,
    name = "Delay group",
    breaks = c("W", "E", "D", "C", "Da", "Sa", "Ca"),
    labels = c(
      "Weather", "Events (non ATC)",
      "Disruptions (non ATC)",
      "Capacity (non ATC)",
      "Disruptions (ATC)",
      "Staffing (ATC)",
      "Capacity (ATC)")) +
  labs(
    x = "Year",
    y = "En-route ATFM delay (min/flight)",
    title = "Yearly en-route ATFM delay",
    subtitle = "Split per delay group") +
  theme(legend.position = c(0.85, 0.8))

ggsave("_assets/images/ert_dly_yyy.png", plot = ert_dly_yyyy_plot)

# library(plotly)
# ggplotly(plot)
