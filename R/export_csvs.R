# export CSVs
# 1. CO2 emissions
# 2. ATC pre-departure delay
# 3. ATFM slot adherence


library(aiuportal)
library(tidyverse)
library(fs)
library(readxl)


dest_dir_root <- "C:/Users/spi/OneDrive - EUROCONTROL/Download data files"
# to production directly
#dest_dir_root <- "\\\\ihx-vdm05\\LIVE_var_www_performance$\\data\\download"
dest_folder <- "csv"

last_month_beg <- today(tzone = "UTC") |> floor_date("month") |> `%m+%`(months(-1))


#---------- co2 emissions ----
export_co2_emissions(wef = "2024-01-01") |>
  arrange(YEAR, MONTH, STATE_NAME) |>
  group_by(YEAR) |>
  group_walk(~ write_csv(
    .x,
    fs::path(dest_dir_root,
             dest_folder,
             stringr::str_glue("co2_emmissions_by_state_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)

# FIX; for when CO2 table not blocked
if (FALSE){
  read_xlsx(
    path = fs::path_abs(
      str_glue("CO2_backup.xlsx"),
      start = '//sky.corp.eurocontrol.int/DFSRoot/Groups/HQ/dgof-pru/Project/DDP/AIU app/data_archive'
      ),
    sheet = "All Data vs Y(-1)",
    range = cell_limits(c(3, 1),
                        c(NA, NA))
    ) %>%
    as_tibble() %>%
    mutate(across(.cols = where(is.instant), ~ as.Date(.x))) %>%
    filter(YEAR>=2019, STATE_NAME != 'LIECHTENSTEIN') %>%
    arrange(2, 3, 4) |> 
    arrange(YEAR, MONTH, STATE_NAME) |>
    group_by(YEAR) |>
    filter(YEAR == 2024) |>
    ungroup() |>
    select(
      YEAR,
      MONTH,
      STATE_NAME,
      STATE_CODE,
      CO2_QTY_TONNES,
      TF) |> 
    dplyr::mutate(
      NOTE = stringr::str_detect(.data$STATE_NAME, "\\*"),
      # remove '*' from State name, if present it is a NOTE
      STATE_NAME = stringr::str_remove(.data$STATE_NAME, "\\*")) |> 
    write_csv(
      fs::path(dest_dir_root,
               dest_folder,
               stringr::str_glue("co2_emmissions_by_state_{YYYY}.csv", YYYY = 2024)),
      na = "")
  
}

#---------- vertical flight efficiency ----
export_vertical_flight_efficiency(wef = "2024-01-01") |>
  # filter out oil rig traffic
  filter(!APT_ICAO %in% c("ENFB", "ENOA", "ENXA")) |>
  # filter out Ukraine as from war start
  mutate(date = lubridate::make_datetime(year = YEAR, month = MONTH_NUM)) |>
  filter(!(STATE_NAME == "Ukraine" & date >= ymd("2022-03-01", tz = "UTC"))) |>
  select(-date) |>
  arrange(YEAR, MONTH_NUM, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder,
             stringr::str_glue("vertical_flight_efficiency_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- atc pre-departure delay (Excel) ----
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

#---------- atc pre-departure delay ----
# ... and then overwrite with what comes from DB
export_atc_predeparture_delay(wef = "2023-01-01") |>
  arrange(YEAR, MONTH_NUM, FLT_DATE, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atc_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- all pre-departure delay (Excel) ----
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

#---------- all pre-departure delay ----
# ... and then overwrite with what comes from DB
export_all_predeparture_delay(wef = "2023-01-01") |>
  arrange(YEAR, MONTH_NUM, FLT_DATE, STATE_NAME, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("all_pre_departure_delays_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- atfm slot adherence ----
# we have data from previous years, BUT Excel starts at 2016
# Export initially from 2016, then from 2024 onward
export_atfm_slot_adherence(wef = "2024-01-01") |>
  arrange(YEAR, MONTH_NUM, FLT_DATE, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("atfm_slot_adherence_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- horizontal flight efficiency ----
export_horizontal_flight_efficiency(wef = "2024-01-01") |>
  arrange(YEAR, MONTH_NUM, ENTRY_DATE, ENTITY_NAME, ENTITY_TYPE, TYPE_MODEL) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("horizontal_flight_efficiency_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- taxi-out additional time ----
export_taxi_out_additional_time(wef = "2018-01-01", til = last_month_beg) |>
  arrange(YEAR, MONTH_NUM, STATE_NAME, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("taxi_out_additional_time_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- taxi-in additional time ----
export_taxi_in_additional_time(wef = "2018-01-01", til = last_month_beg) |>
  arrange(YEAR, MONTH_NUM, STATE_NAME, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("taxi_in_additional_time_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- asma additional time ----
export_asma_additional_time(wef = "2018-01-01", til = last_month_beg) |>
  arrange(YEAR, MONTH_NUM, STATE_NAME, APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("asma_additional_time_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)


#---------- airport traffic (Excel) ----
# DB contains only from 2020...so spit from Excel first...
# excel <- "Airport_Traffic.xlsx"
# aa <- read_xlsx(fs::path(dest_dir_root, excel), sheet = "DATA")
# aa |>
#   dplyr::select(-`Pivot Label`) |>
#   dplyr::mutate(FLT_DATE = lubridate::as_date(.data$FLT_DATE, tz = "UTC")) |>
#   dplyr::arrange(YEAR,
#                  MONTH_NUM,
#                  FLT_DATE,
#                  STATE_NAME,
#                  APT_ICAO) |>
#   group_by(YEAR) |>
#   group_walk(~ write_csv(
#     .x,
#     fs::path(dest_dir_root,
#              dest_folder ,
#              stringr::str_glue("airport_traffic_{YYYY}.csv", YYYY = .y$YEAR)),
#     na = ""),
#     .keep = TRUE)

#---------- airport traffic ----
export_airport_traffic(wef = "2024-01-01") |>
  dplyr::arrange(YEAR,
                 MONTH_NUM,
                 FLT_DATE,
                 STATE_NAME,
                 APT_ICAO) |>
  group_by(YEAR) |> 
  group_walk(~ write_csv(
    .x, 
    fs::path(dest_dir_root,
             dest_folder ,
             stringr::str_glue("airport_traffic_{YYYY}.csv", YYYY = .y$YEAR)),
    na = ""),
    .keep = TRUE)
