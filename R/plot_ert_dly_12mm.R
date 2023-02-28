library(dplyr)
library(ggplot2)
library(viridis)
library(lubridate)

source("R/read_ert_dly.R")
year_end <- floor_date(Sys.Date(), "month")
year_start <- year_end - years(1)

ectrl_details_mm12 <- ectrl_details %>%
  filter(date >= year_start & date < year_end) %>%
  group_by(yyyy, mm, delay_group) %>%
  summarise(delay = sum(delay))

ectrl_summaries_mm12 <- ectrl_summaries %>%
  filter(date >= year_start & date < year_end) %>%
  group_by(yyyy, mm) %>%
  summarise(flt_tot = sum(flights), flt_dly = sum(flights_delayed), flt_dly_gt15 = sum(flights_delayed_gt15))


ectrl_mm12 <- inner_join(ectrl_details_mm12, ectrl_summaries_mm12, by = c("yyyy", "mm")) %>%
  mutate(date = ymd(str_c(yyyy, mm, "01", sep = "-")))


g <- ggplot(ectrl_mm12, aes(x = date, y = delay/flt_tot, fill = delay_group))

ert_dly_12m_plot <- g +
  geom_bar(stat = "identity") +
  scale_x_date(
    date_labels = "%b-%Y",
    date_breaks = "1 month") +
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
    x = "Month",
    y = "En-route ATFM delay (min/flight)",
    title = "Last year monthly en-route ATFM delay",
    subtitle = "Split per delay group") +
  theme(legend.position = c(0.85, 0.8))

ggsave("_assets/images/ert_dly_12mm.png", plot = ert_dly_12m_plot)

# library(plotly)
# ggplotly(plot)
