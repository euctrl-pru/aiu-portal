# export CSVs
# 1. CO2 emissions
# 2. ATC pre-departure delay
# 3. ATFM slot adherence


library(aiuportal)
library(tidyverse)
# library(here)
library(fs)
library(readxl)


dest_dir_root <- "C:\\Users\\spi\\EUROCONTROL\\ECTL - Aviation Intelligence Unit - AIU Portal\\Download data files"
dest_folder <- "csv"

export_co2_emissions(wef = "2000-01-01") -> cc
cc |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder,
             stringr::str_glue("co2_emmissions_by_state_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""))

export_vertical_flight_efficiency(wef = "2000-01-01") -> vv
vv |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder,
             stringr::str_glue("vertical_flight_efficiency_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""))


# DB contains only last 2 years...so spit from Excel first...
excel <- "ATC_Pre-Departure_Delay.xlsx"
aa <- read_xlsx(fs::path(dest_dir_root, excel), sheet = "DATA")
aa |>
  dplyr::select(-`Pivot Label`) |>
  dplyr::mutate(FLT_DATE = lubridate::as_date(.data$FLT_DATE, tz = "UTC")) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atc_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)), 
    na = ""))

# ... and then overwrite with what comes from DB
export_atc_predeparture_delay(wef = "2000-01-01") -> aa
aa |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atc_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""))

# we have data from previous years, BUT Excel starts at 2016
export_atfm_slot_adherence(wef = "2016-01-01") -> ss
ss |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atfm_slot_adherence_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""))

