# export CSVs
# 1. CO2 emissions
# 2. ATC pre-departure delay
# 3. ATFM slot adherence


library(aiuportal)
library(tidyverse)
library(fs)
library(readxl)


dest_dir_root <- "C:\\Users\\spi\\EUROCONTROL\\ECTL - Aviation Intelligence Unit - AIU Portal\\Download data files"
dest_folder <- "csv"

export_co2_emissions(wef = "2024-01-01") -> cc
cc |>
  arrange(YEAR, MONTH, STATE_NAME) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder,
             stringr::str_glue("co2_emmissions_by_state_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)

export_vertical_flight_efficiency(wef = "2024-01-01") -> vv
vv |>
  arrange(YEAR, MONTH_NUM, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder,
             stringr::str_glue("vertical_flight_efficiency_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


# DB contains only last 2 years...so spit from Excel first...
# excel <- "ATC_Pre-Departure_Delay.xlsx"
# aa <- read_xlsx(fs::path(dest_dir_root, excel), sheet = "DATA")
# aa |>
#   dplyr::select(-`Pivot Label`) |>
#   dplyr::mutate(FLT_DATE = lubridate::as_date(.data$FLT_DATE, tz = "UTC")) |>
#   arrange(YEAR, MONTH_NUM, FLT_DATE, APT_ICAO) |>
#   group_by(YEAR) |>
#   group_walk(~ write_csv(
#     .x,
#     fs::path(dest_dir_root,
#              dest_folder ,
#              stringr::str_glue("atc_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
#     na = ""),
#     .keep = TRUE)

# ... and then overwrite with what comes from DB
export_atc_predeparture_delay(wef = "2023-01-01") -> aa
aa |>
  arrange(YEAR, MONTH_NUM, FLT_DATE, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atc_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


# DB contains only last 2 years...so spit from Excel first...
# excel <- "ALL_Pre-Departure_Delay.xlsx"
# ll <- read_xlsx(fs::path(dest_dir_root, excel), sheet = "DATA")
# ll |>
#   dplyr::select(-`Pivot Label`) |>
#   dplyr::mutate(FLT_DATE = lubridate::as_date(.data$FLT_DATE, tz = "UTC")) |>
#   arrange(YEAR, MONTH_NUM, FLT_DATE, STATE_NAME, APT_ICAO) |>
#   group_by(YEAR) |>
#   group_walk(~ write_csv(
#     .x,
#     fs::path(dest_dir_root,
#              dest_folder ,
#              stringr::str_glue("all_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
#     na = ""),
#     .keep = TRUE)

# ... and then overwrite with what comes from DB
export_all_predeparture_delay(wef = "2023-01-01") -> ll
ll |>
  arrange(YEAR, MONTH_NUM, FLT_DATE, STATE_NAME, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("all_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


# we have data from previous years, BUT Excel starts at 2016
# Export initially from 2016, then from 2024 onward
export_atfm_slot_adherence(wef = "2024-01-01") -> ss
ss |>
  arrange(YEAR, MONTH_NUM, FLT_DATE, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atfm_slot_adherence_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


export_horizontal_flight_efficiency(wef = "2024-01-01") -> hh
hh |>
  arrange(YEAR, MONTH_NUM, ENTRY_DATE, ENTITY_NAME, ENTITY_TYPE, TYPE_MODEL) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("horizontal_flight_efficiency_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)

