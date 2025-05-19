# script to extract CO2 emission for use in
# CO2 map embedded in here:
#   https://ansperformance.eu/efficiency/emissions
# The map is done in Observable and hosted here:
# https://observablehq.com/@espinielli/co2-emissions-variation-per-state
# the new data in mom_co2.csv have to be attached in the notebook
# via File attachments -> Replace file
# Also copy on HARDOCODED OneDrive
#
# NOTE: copy to CSVs to production done when rendering
#       content/efficiency/emissions.Rmd

library(dplyr)
library(eurocontrol)
library(stringr)
library(lubridate)
library(readr)
library(readxl)


check_co2 <- try({
  co2_data_raw <- export_query("PRU_DEV", query = query) %>%
    mutate(across(.cols = where(is.instant), ~ as.Date(.x)))
}) # Check if an error occurred
if (inherits(check_co2, "try-error")) {
  co2_data_raw <- read_xlsx(
    path = fs::path_abs(
      str_glue("CO2_backup.xlsx"),
      start = '//sky.corp.eurocontrol.int/DFSRoot/Groups/HQ/dgof-pru/Project/DDP/AIU app/data_archive'
    ),
    sheet = "All Data vs Y(-1)",
    range = cell_limits(c(3, 1), c(NA, NA))
  ) %>%
    as_tibble() %>%
    mutate(across(.cols = where(is.instant), ~ as.Date(.x))) %>%
    filter(YEAR >= 2019, STATE_NAME != 'LIECHTENSTEIN') %>%
    arrange(2, 3, 4)
} else {
  co2_data_raw <- export_query("PRU_DEV", query = query) %>%
    mutate(across(.cols = where(is.instant), ~ as.Date(.x)))
}

co2_data_mm <- co2_data_raw %>%
  select(FLIGHT_MONTH, CO2_QTY_TONNES, TF, YEAR, MONTH) %>%
  group_by(FLIGHT_MONTH) %>%
  summarise(
    TTF = sum(TF),
    TCO2 = sum(CO2_QTY_TONNES),
    NULL
  ) %>%
  mutate(
    YEAR = year(FLIGHT_MONTH),
    MONTH = month(FLIGHT_MONTH)
  ) %>%
  arrange(FLIGHT_MONTH) %>%
  mutate(
    TTF_IDX = TTF / first(TTF) * 100,
    CO2_IDX = TCO2 / first(TCO2) * 100
  )

check_flights <- co2_data_mm %>%
  filter(YEAR == max(YEAR)) %>%
  filter(MONTH == max(MONTH)) %>%
  select(TTF) %>%
  pull()

if (check_flights < 1000) {
  co2_data_raw <- co2_data_raw %>%
    filter(FLIGHT_MONTH < max(FLIGHT_MONTH))
  co2_data_mm <- co2_data_mm %>%
    filter(FLIGHT_MONTH < max(FLIGHT_MONTH))
}


# data month state
last_date <- max(co2_data_raw$FLIGHT_MONTH, na.rm = TRUE)
last_month <- format(last_date, '%B')
last_year <- max(co2_data_raw$YEAR)

co2_data_mom_state <- co2_data_raw %>%
  aiuportal::month_on_month_co2_emissions()


# data y2d  state

co2_data_y2d_state <- co2_data_raw |>
  aiuportal::year_to_date_co2_emissions()


co2_data_mom_state %>%
  write_csv(
    "C:/Users/spi/OneDrive - EUROCONTROL/Download data files/csv/mom_co2.csv"
  )
co2_data_y2d_state %>%
  write_csv(
    "C:/Users/spi/OneDrive - EUROCONTROL/Download data files/csv/y2d_co2.csv"
  )
