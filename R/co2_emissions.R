# script to extract CO2 emission for use in 
# CO2 map embedded in here:
#   https://ansperformance.eu/efficiency/emissions
# The map is done in Obersevable and hosted here:
# https://observablehq.com/@espinielli/co2-emissions-variation-per-state
# the new data in mom_co2.csv have to be attached in the notebook
# via File attachments -> Replace file

library(dplyr)
library(eurocontrol)
library(stringr)
library(lubridate)
library(readr)

round_away_from_zero <- function(x) {
  sign(x) * ceiling(abs(x))
}


country_ids <- tibble::tribble(
      ~id, ~id2,
    "ISL", "BI",
    "KOS", "BK",
    "MNE", "BY", # separate it from Serbia, LY
    "BEL", "EB",
    "DEU", "ED",
    "EST", "EE",
    "FIN", "EF",
    "GBR", "EG",
    "NLD", "EH",
    "IRL", "EI",
    "DNK", "EK",
    "LUX", "EL",
    "NOR", "EN",
    "POL", "EP",
    "SWE", "ES",
    "LVA", "EV",
    "LTU", "EY",
    "CANY","GC",
    "MAR", "GM",
    "ALB", "LA",
    "BGR", "LB",
    "CYP", "LC",
    "HRV", "LD",
    "ESP", "LE",
    "FRA", "LF",
    "GRC", "LG",
    "HUN", "LH",
    "ITA", "LI",
    "SVN", "LJ",
    "CZE", "LK",
    "ISR", "LL",
    "MLT", "LM",
    "MCO", "LN",
    "AUT", "LO",
    "PRT", "LP",
    "BIH", "LQ",
    "ROU", "LR",
    "CHE", "LS",
    "TUR", "LT",
    "MDA", "LU",
    "MKD", "LW",
    "SRB", "LY",
    "SVK", "LZ",
    "ARM", "UD",
    "GEO", "UG",
    "UKR", "UK"
  )

com_ids <- tibble::tribble(
             ~Country_name, ~ISO, ~iso_3166,
                 "Albania", "AL",     "ALB",
                 "Armenia", "AM",     "ARM",
                 "Austria", "AT",     "AUT",
                 "Belgium", "BE",     "BEL",
  "Bosnia and Herzegovina", "BA",     "BIH",
                "Bulgaria", "BG",     "BGR",
          "Canary Islands", "ES",     "ESP",
                 "Croatia", "HR",     "HRV",
                  "Cyprus", "CY",     "CYP",
          "Czech Republic", "CZ",     "CZE",
                 "Denmark", "DK",     "DNK",
                 "Estonia", "EE",     "EST",
                 "Finland", "FI",     "FIN",
                  "France", "FR",     "FRA",
                 "Georgia", "GE",     "GEO",
                 "Germany", "DE",     "DEU",
                  "Greece", "GR",     "GRC",
                 "Hungary", "HU",     "HUN",
                 "Iceland", "IS",     "ISL",
                 "Ireland", "IE",     "IRL",
                   "Italy", "IT",     "ITA",
                  "Kosovo", "XK",     "XKS",
                  "Latvia", "LV",     "LVA",
               "Lithuania", "LT",     "LTU",
              "Luxembourg", "LU",     "LUX",
                   "Malta", "MT",     "MLT",
     "Republic of Moldova", "MD",     "MDA",
                  "Monaco", "MC",     "MCO",
              "Montenegro", "ME",     "MNE",
         "The Netherlands", "NL",     "NLD",
         "North Macedonia", "MK",     "MKD",
                  "Norway", "NO",     "NOR",
                  "Poland", "PL",     "POL",
                "Portugal", "PT",     "PRT",
                 "Romania", "RO",     "ROU",
                  "Serbia", "RS",     "SRB",
                "Slovakia", "SK",     "SVK",
                "Slovenia", "SI",     "SVN",
                   "Spain", "ES",     "ESP",
                  "Sweden", "SE",     "SWE",
             "Switzerland", "CH",     "CHE",
                 "Türkiye", "TR",     "TUR",
          "United Kingdom", "GB",     "GBR"
  )



export_query <- function(schema, query) {
  withr::local_envvar(c("TZ" = "UTC", "ORA_SDTZ" = "UTC"))
  con <- withr::local_db_connection(eurocontrol::db_connection(schema))
  con %>%
    DBI::dbSendQuery(query) %>%
    DBI::fetch(n = -1)
}

query <- str_glue("
    SELECT *
      FROM TABLE (emma_pub.api_aiu_stats.MM_AIU_STATE_DEP ())
      where year >= 2019 and STATE_NAME not in ('LIECHTENSTEIN')
    ORDER BY 2, 3, 4
   ")


co2_data_raw <- export_query(schema = "PRU_DEV", query = query) %>%
  mutate(across(.cols = where(is.instant), ~ as.Date(.x))) %>%
  as_tibble()

co2_data_mm <- co2_data_raw %>%
  select(FLIGHT_MONTH, CO2_QTY_TONNES, TF, YEAR, MONTH) %>%
  group_by(FLIGHT_MONTH) %>%
  summarise(
    TTF = sum(TF),
    TCO2 = sum(CO2_QTY_TONNES),
    NULL) %>%
  mutate(
    YEAR  = year(FLIGHT_MONTH),
    MONTH = month(FLIGHT_MONTH)) %>%
  arrange(FLIGHT_MONTH) %>%
  mutate(
    TTF_IDX = TTF  / first(TTF)  * 100,
    CO2_IDX = TCO2 / first(TCO2) * 100)

check_flights <- co2_data_mm %>%
  filter (YEAR == max(YEAR)) %>%
  filter(MONTH == max(MONTH)) %>%
  select(TTF) %>% pull()

if (check_flights < 1000) {
  co2_data_raw <-  co2_data_raw %>%
    filter (FLIGHT_MONTH < max(FLIGHT_MONTH))
  co2_data_mm <- co2_data_mm %>%
    filter (FLIGHT_MONTH < max(FLIGHT_MONTH))

}


# data month state
last_date  <- max(co2_data_raw$FLIGHT_MONTH, na.rm=TRUE)
last_month <- format(last_date,'%B')
last_year  <- max(co2_data_raw$YEAR)

co2_data_mom_state <- co2_data_raw %>%
  arrange(STATE_NAME, YEAR, MONTH) %>%
  mutate(
    MOM_GROWTH_CO2 = if_else(
      YEAR == last_year,
      CO2_QTY_TONNES / lag(CO2_QTY_TONNES, 12 * (last_year - 2019)) - 1,
      NA),
    MOM_GROWTH_TF = if_else(
      YEAR == last_year,
      TF / lag(TF, 12 * (last_year - 2019)) - 1,
      NA)
  ) %>%
  filter(FLIGHT_MONTH == last_date) %>%
  # select(STATE_NAME, STATE_CODE, YEAR, MONTH, CO2_QTY_TONNES, TF, MOM_GROWTH_CO2, MOM_GROWTH_TF) %>%
  mutate(STATE_NAME = gsub("(?<=\\b)([a-z])", "\\U\\1", tolower(STATE_NAME), perl = TRUE)) %>%
  mutate(STATE_NAME = gsub("Of", "of",STATE_NAME, ignore.case = FALSE)) %>%
  mutate(STATE_NAME = gsub("And", "and",STATE_NAME, ignore.case = FALSE)) %>%
  mutate(STATE_NAME = gsub("TüRkiye", "Türkiye",STATE_NAME, ignore.case = FALSE)) %>%
  select(STATE_NAME, STATE_CODE, YEAR, MONTH, MOM_GROWTH_CO2) %>%
  # detach Montenegro from Serbia
  mutate(STATE_CODE = if_else(STATE_NAME == "Montenegro", "BY", STATE_CODE)) %>%
  left_join(country_ids, by = c("STATE_CODE" = "id2"))





# data y2d  state

co2_data_y2d_state <- co2_data_raw %>%
  arrange(STATE_NAME, YEAR, MONTH) %>%
  group_by(STATE_NAME, YEAR) %>%
  mutate(
    YTD_CO2_QTY_TONNES = cumsum(CO2_QTY_TONNES),
    YTD_TF = cumsum(TF)
  ) %>%
  ungroup() %>%
  mutate(
    YTD_GROWTH_CO2 = if_else(YEAR == last_year,
                             YTD_CO2_QTY_TONNES / lag(YTD_CO2_QTY_TONNES, 12 * (last_year - 2019)) - 1,
                             NA),
    YTD_GROWTH_TF = if_else(YEAR == last_year, YTD_TF / lag(YTD_TF, 12 * (last_year - 2019)) - 1,
                            NA)
  ) %>%
  filter(FLIGHT_MONTH == last_date) %>%
  select(STATE_NAME, STATE_CODE, YEAR, MONTH, YTD_CO2_QTY_TONNES, YTD_TF, YTD_GROWTH_CO2, YTD_GROWTH_TF) %>%
  mutate(STATE_NAME = gsub("(?<=\\b)([a-z])", "\\U\\1", tolower(STATE_NAME), perl=TRUE)) %>%
  mutate(STATE_NAME = gsub("Of", "of", STATE_NAME, ignore.case = FALSE)) %>%
  mutate(STATE_NAME = gsub("And", "and", STATE_NAME, ignore.case = FALSE)) %>%
  mutate(STATE_NAME = gsub("Turkiye", "Türkiye", STATE_NAME, ignore.case = FALSE)) %>%
  select(STATE_NAME, STATE_CODE, YEAR, MONTH, YTD_GROWTH_CO2) %>%
  # detach Montenegro from Serbia
  mutate(STATE_CODE = if_else(STATE_NAME == "Montenegro", "BY", STATE_CODE)) %>%
  left_join(country_ids, by = c("STATE_CODE" = "id2"))





co2_data_mom_state %>%
  write_csv("mom_co2.csv")
co2_data_y2d_state %>%
  write_csv("y2d_co2.csv")

# ---------------------------------
# We used to put the files in the download/csv/ as served by the Agency's website
# and then read directly by Observable but CORS got in the way

# dest_dir <- "//ihx-vdm05/LIVE_var_www_performance$/data/download/csv/"
# 
# fname <- "mom_co2.csv"
# sour_fname <- here::here(fname)
# dest_fname <- fname |> fs::path_abs(start = dest_dir)
# fs::file_copy(sour_fname, dest_fname, overwrite = TRUE)
# 
# fname <- "y2d_co2.csv"
# sour_fname <- here::here(fname)
# dest_fname <- fname |> fs::path_abs(start = dest_dir)
# fs::file_copy(sour_fname, dest_fname, overwrite = TRUE)
