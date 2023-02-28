#!/usr/bin/env Rscript

"Generate yearly en-route ATFM traffic (and % change) per ANSP (AUA based) for graphics.

Usage: generate_ert_flt_percent_change [-h] TIL

-h --help             show this help text
TIL                   year, month and day (YYYY-MM-DD, i.e. 2017-08-01) till when compute (non inclusive)
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

suppressMessages(library(lubridate))
suppressMessages(library(purrr))

safe_ymd <- safely(ymd)
til <- safe_ymd(opts$TIL, quiet = TRUE)

if (is.null(til$result)) {
  cat("Error: invalid TIL, it must be in YYYY-MM-DD format", "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  til <- til$result
  curr <- til - months(1)
  prev_year <-  year(curr - years(1))
  curr_month <- month(curr)
  curr_year <- year(curr)
}



suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(stringr))
suppressMessages(library(tidyr))


ftype <- "ansp"
csvs <- list.files(
  here::here("static", "download", "csv"),
  pattern = stringr::str_c("ert_dly_", ftype,"_\\d{4}\\.csv\\.bz2"),
  full.names = TRUE)


get_ert_flt <- function(path) {
  col_types <- cols(
    # HACK: read doubles by default and then cast to integer
    # FIX: fix on write_csv
    .default = col_double(),
    YEAR = col_integer(),
    MONTH_NUM = col_integer(),
    MONTH_MON = col_character(),
    FLT_DATE = col_datetime(format = ""),
    ENTITY_NAME = col_character(),
    ENTITY_TYPE = col_character()
    )

  read_csv(path, col_types = col_types) %>%
    mutate(
      FLT_ERT_1 = as.integer(FLT_ERT_1),
      DLY_ERT_1 = as.integer(DLY_ERT_1),
      DLY_ERT_A_1 = as.integer(DLY_ERT_A_1),
      DLY_ERT_C_1 = as.integer(DLY_ERT_C_1),
      DLY_ERT_D_1 = as.integer(DLY_ERT_D_1),
      DLY_ERT_E_1 = as.integer(DLY_ERT_E_1),
      DLY_ERT_G_1 = as.integer(DLY_ERT_G_1),
      DLY_ERT_I_1 = as.integer(DLY_ERT_I_1),
      DLY_ERT_M_1 = as.integer(DLY_ERT_M_1),
      DLY_ERT_N_1 = as.integer(DLY_ERT_N_1),
      DLY_ERT_O_1 = as.integer(DLY_ERT_O_1),
      DLY_ERT_P_1 = as.integer(DLY_ERT_P_1),
      DLY_ERT_R_1 = as.integer(DLY_ERT_R_1),
      DLY_ERT_S_1 = as.integer(DLY_ERT_S_1),
      DLY_ERT_T_1 = as.integer(DLY_ERT_T_1),
      DLY_ERT_V_1 = as.integer(DLY_ERT_V_1),
      DLY_ERT_W_1 = as.integer(DLY_ERT_W_1),
      DLY_ERT_NA_1 = as.integer(DLY_ERT_NA_1)
    ) %>%
    arrange(FLT_DATE, ENTITY_NAME)
}


all <- csvs %>%
  map(get_ert_flt) %>%
  bind_rows()

all <- all %>%
  filter(YEAR >= prev_year, MONTH_NUM >=1, MONTH_NUM <= curr_month) %>%
  rename(entity = ENTITY_NAME) %>%
  group_by(YEAR, entity) %>%
  summarise(flt = sum(FLT_ERT_1)) %>%
  ungroup()

all %>%
  # IMPORTANT because order matters for percentance change
  arrange(entity, YEAR) %>%
  spread(YEAR, flt) %>% 
  filter(!entity %in% c("NAV Portugal")) %>% 
  mutate(prc_change = round(100 *((.[[3]]) - (.[[2]])) / (.[[2]]), digits = 2)) %>%
  write_tsv(here::here("content", "graphic", "percent-movement-change", "ert-flt-ansp.tsv"))
