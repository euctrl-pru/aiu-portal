#!/usr/bin/env Rscript

"Generate monthly en-route ATFM delay per FAB (FIR based) for graphics.

Usage: generate_ert_dly_fab_fir [-h] [-o DIR]

-h --help             show this help text
-o DIR              directory where to save the output [default: .]
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)
out_dir <- opts$o


suppressMessages(library(readr))
suppressMessages(library(stringr))
suppressMessages(library(tidyr))
suppressMessages(library(purrr))
suppressMessages(library(dplyr))
suppressWarnings(suppressMessages(library(fs)))


if (!fs::dir_exists(out_dir)) {
  cat("Error: non-existing DIR", "\n")
  cat(doc, "\n")
  q(status = -1)
}

out_dir <- fs::path_abs(out_dir)


ftype <- "fir"
csvs <- list.files(
  out_dir,
  pattern = str_c("ert_dly_", ftype,"_\\d{4}\\.csv\\.bz2"),
  full.names = TRUE)


get_ert_dly <- function(path) {
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
  map(get_ert_dly) %>%
  bind_rows() %>%
  filter(ENTITY_TYPE == "FAB (FIR)", ENTITY_NAME != "FAB CE (SES RP1)", ENTITY_NAME != "FAB CE") %>%
  select(YEAR, MONTH_NUM, FLT_DATE, ENTITY_NAME, FLT_ERT_1, DLY_ERT_1) %>%
  replace_na(replace = list(FLT_ERT_1= 0, DLY_ERT_1 = 0)) %>%
  group_by(YEAR, ENTITY_NAME) %>%
  summarise(flt = sum(FLT_ERT_1), dly = sum(DLY_ERT_1), avg = ifelse(flt == 0, 0, dly / flt)) %>%
  write_csv(here::here("content", "graphic", "en-route-atfm-delay-fab","monthly-ert-dly-fab-fir.csv"))
