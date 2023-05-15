#!/usr/bin/env Rscript

"Export en-route daily delay and traffic to yearly CSV files.

Usage: export_ert_dly [-h] [-t TYPE] [-o DIR] WEF TIL

  -h --help             show this help text
  -t TYPE, --type=TYPE  the TYPE of entity; one of ansp, fir [default: ansp]
  -o DIR                directory where to save the output [default: .]

Arguments:
  WEF  date from when to export data, format YYYY-MM-DD
  TIL  date till when to export data, format YYYY-MM-DD (non-inclusive)
  DIR  directory where to save the data file
" -> doc

suppressWarnings(suppressMessages(library(docopt)))

# retrieve the command-line arguments
opts <- docopt(doc)

types <- c("ansp", "fir")

if (!(opts$type %in% types)) {
  cat("Error: incorrect TYPE, it must be one of", paste0(types, collapse = ", "), "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  type <- opts$type
}

suppressWarnings(suppressMessages(library(lubridate)))
suppressWarnings(suppressMessages(library(purrr)))
suppressWarnings(suppressMessages(library(fr24gu)))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))
suppressWarnings(suppressMessages(library(fs)))

safe_ymd <- safely(ymd)
wef <- safe_ymd(opts$WEF, quiet = TRUE)
til <- safe_ymd(opts$TIL, quiet = TRUE)
out_dir <- opts$o


if (is.null(wef$result) || is.null(til$result)) {
  cat("Error: invalid WEF and/or TIL, it must be in YYYY-MM-DD format", "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  wef <- format(wef$result, "%Y-%m-%d")
  til <- format(til$result, "%Y-%m-%d")
}


if (!fs::dir_exists(out_dir)) {
  cat("Error: non-existing DIR", "\n")
  cat(doc, "\n")
  q(status = -1)
}

out_dir <- fs::path_abs(out_dir)



# # NOTE: to be set before you create your ROracle connection!
# # See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
# tz <- "UDT"
# Sys.setenv("TZ" = tz)
# Sys.setenv("ORA_SDTZ" = "UTC")


con <- db_connection(schema = "PRU_DEV")


extract_dly_ansp <- function(con, wef, til) {
  t_base <- con |> 
    tbl("V_PRU_FAC_TDC_DD") |> 
    filter(to_date(wef, 'YYYY-MM-DD') <= ENTRY_DATE, ENTRY_DATE < to_date(til, 'YYYY-MM-DD'))
  
  t1 <- t_base |> 
    filter((UNIT_PRU_TYPE == 'ZONE' && UNIT_ID %in% c(58L)) || (UNIT_PRU_TYPE == 'ZONE_ANSP' && UNIT_ID %in% c(55L))) |> 
    mutate(
      YEAR = year(ENTRY_DATE),
      MONTH_NUM = month(ENTRY_DATE),
      MONTH_MON = sql("TO_CHAR(ENTRY_DATE, 'MON')"),
      ENTITY_NAME = case_when(
        UNIT_NAME == 'EUROCONTROL' ~ 'EUROCONTROL Area (MS)',
        UNIT_NAME == 'SES Performance Scheme SES-RP1 based on ANSP' ~ 'SES Area (RP1)',
        TRUE ~ UNIT_NAME
      ),
      ENTITY_TYPE = 'AREA (AUA)',
      NULL
    ) |> 
    select(
      YEAR,
      MONTH_NUM,
      MONTH_MON,
      FLT_DATE = ENTRY_DATE,
      ENTITY_NAME,
      ENTITY_TYPE,
      FLT_ERT_1 = TTF_FLT,
      DLY_ERT_1 = TDM_ERT,
      DLY_ERT_A_1 = TDM_ERT_A, 
      DLY_ERT_C_1 = TDM_ERT_C, 
      DLY_ERT_D_1 = TDM_ERT_D, 
      DLY_ERT_E_1 = TDM_ERT_E,
      DLY_ERT_G_1 = TDM_ERT_G, 
      DLY_ERT_I_1 = TDM_ERT_I, 
      DLY_ERT_M_1 = TDM_ERT_M, 
      DLY_ERT_N_1 = TDM_ERT_N, 
      DLY_ERT_O_1 = TDM_ERT_O,
      DLY_ERT_P_1 = TDM_ERT_P, 
      DLY_ERT_R_1 = TDM_ERT_R, 
      DLY_ERT_S_1 = TDM_ERT_S, 
      DLY_ERT_T_1 = TDM_ERT_T, 
      DLY_ERT_V_1 = TDM_ERT_V, 
      DLY_ERT_W_1 = TDM_ERT_W,
      DLY_ERT_NA_1 = TDM_ERT_NA,
      FLT_ERT_1_DLY = TDF_ERT,
      FLT_ERT_1_DLY_15 = TDF_15_ERT
    )
  
  t2 <- t_base |> 
    filter(
      UNIT_PRU_TYPE == 'ANSP',
      !UNIT_NAME %in% c('NATS','NATS (Oceanic)','HungaroControl','Israel AA', 'ONDA',
                        'UkSATSE', 'Avinor (Continental)','Avinor (Oceanic)',
                        'NAV Portugal (Santa Maria)', 'UNKNOWN',
                        'MILITARY','AIRPORT','PIA','BHANSA', 'KFOR (HungaroControl)')
    ) |> 
    mutate(
      YEAR = year(ENTRY_DATE),
      MONTH_NUM = month(ENTRY_DATE),
      MONTH_MON = sql("TO_CHAR(ENTRY_DATE, 'MON')"),
      ENTITY_TYPE = 'ANSP (AUA)',
      ENTITY_NAME = UNIT_NAME,
      NULL
    ) |> 
    select(
      YEAR,
      MONTH_NUM,
      MONTH_MON,
      FLT_DATE = ENTRY_DATE,
      ENTITY_NAME,
      ENTITY_TYPE,
      FLT_ERT_1 = TTF_FLT,
      DLY_ERT_1 = TDM_ERT,
      DLY_ERT_A_1 = TDM_ERT_A, 
      DLY_ERT_C_1 = TDM_ERT_C, 
      DLY_ERT_D_1 = TDM_ERT_D, 
      DLY_ERT_E_1 = TDM_ERT_E,
      DLY_ERT_G_1 = TDM_ERT_G, 
      DLY_ERT_I_1 = TDM_ERT_I, 
      DLY_ERT_M_1 = TDM_ERT_M, 
      DLY_ERT_N_1 = TDM_ERT_N, 
      DLY_ERT_O_1 = TDM_ERT_O,
      DLY_ERT_P_1 = TDM_ERT_P, 
      DLY_ERT_R_1 = TDM_ERT_R, 
      DLY_ERT_S_1 = TDM_ERT_S, 
      DLY_ERT_T_1 = TDM_ERT_T, 
      DLY_ERT_V_1 = TDM_ERT_V, 
      DLY_ERT_W_1 = TDM_ERT_W,
      DLY_ERT_NA_1 = TDM_ERT_NA,
      FLT_ERT_1_DLY = TDF_ERT,
      FLT_ERT_1_DLY_15 = TDF_15_ERT
    )
  
  
  df_ansp <- t1 |> union_all(t2) |> collect()
  
  df_ansp
}

extract_dly_fir <- function(con, wef, til) {
  t_base <- con |> 
    tbl("V_PRU_FAC_TDC_DD") |> 
    filter(to_date(wef, 'YYYY-MM-DD') <= ENTRY_DATE, ENTRY_DATE < to_date(til, 'YYYY-MM-DD'))
  
  
  t1 <- t_base |> 
    filter(
      (UNIT_PRU_TYPE == 'ZONE_FIR' && UNIT_ID %in% c(56L)),
      to_date('2015-01-01', 'YYYY-MM-DD') <= ENTRY_DATE) |> 
    mutate(
      YEAR = year(ENTRY_DATE),
      MONTH_NUM = month(ENTRY_DATE),
      MONTH_MON = sql("TO_CHAR(ENTRY_DATE, 'MON')"),
      ENTITY_NAME = case_when(
        UNIT_NAME == 'SES Performance Scheme SES-RP2 based on FIR' ~ 'SES Area (RP2)',
        TRUE ~ UNIT_NAME
      ),
      ENTITY_TYPE = 'AREA (FIR)',
      NULL
    ) |> 
    select(
      YEAR,
      MONTH_NUM,
      MONTH_MON,
      FLT_DATE = ENTRY_DATE,
      ENTITY_NAME,
      ENTITY_TYPE,
      FLT_ERT_1 = TTF_FLT,
      DLY_ERT_1 = TDM_ERT,
      DLY_ERT_A_1 = TDM_ERT_A, 
      DLY_ERT_C_1 = TDM_ERT_C, 
      DLY_ERT_D_1 = TDM_ERT_D, 
      DLY_ERT_E_1 = TDM_ERT_E,
      DLY_ERT_G_1 = TDM_ERT_G, 
      DLY_ERT_I_1 = TDM_ERT_I, 
      DLY_ERT_M_1 = TDM_ERT_M, 
      DLY_ERT_N_1 = TDM_ERT_N, 
      DLY_ERT_O_1 = TDM_ERT_O,
      DLY_ERT_P_1 = TDM_ERT_P, 
      DLY_ERT_R_1 = TDM_ERT_R, 
      DLY_ERT_S_1 = TDM_ERT_S, 
      DLY_ERT_T_1 = TDM_ERT_T, 
      DLY_ERT_V_1 = TDM_ERT_V, 
      DLY_ERT_W_1 = TDM_ERT_W,
      DLY_ERT_NA_1 = TDM_ERT_NA,
      FLT_ERT_1_DLY = TDF_ERT,
      FLT_ERT_1_DLY_15 = TDF_15_ERT
    )
  
  
  
  
  t2 <- t_base |> 
    filter(
      UNIT_PRU_TYPE == 'FAB_FIR',
      !UNIT_NAME %in% c('BLUE MED FAB (+Albania)'),
      to_date('2015-01-01', 'YYYY-MM-DD') <= ENTRY_DATE
    ) |> 
    mutate(
      YEAR = year(ENTRY_DATE),
      MONTH_NUM = month(ENTRY_DATE),
      MONTH_MON = sql("TO_CHAR(ENTRY_DATE, 'MON')"),
      ENTITY_TYPE = 'FAB (FIR)',
      ENTITY_NAME = UNIT_NAME,
      NULL
    ) |> 
    select(
      YEAR,
      MONTH_NUM,
      MONTH_MON,
      FLT_DATE = ENTRY_DATE,
      ENTITY_NAME,
      ENTITY_TYPE,
      FLT_ERT_1 = TTF_FLT,
      DLY_ERT_1 = TDM_ERT,
      DLY_ERT_A_1 = TDM_ERT_A, 
      DLY_ERT_C_1 = TDM_ERT_C, 
      DLY_ERT_D_1 = TDM_ERT_D, 
      DLY_ERT_E_1 = TDM_ERT_E,
      DLY_ERT_G_1 = TDM_ERT_G, 
      DLY_ERT_I_1 = TDM_ERT_I, 
      DLY_ERT_M_1 = TDM_ERT_M, 
      DLY_ERT_N_1 = TDM_ERT_N, 
      DLY_ERT_O_1 = TDM_ERT_O,
      DLY_ERT_P_1 = TDM_ERT_P, 
      DLY_ERT_R_1 = TDM_ERT_R, 
      DLY_ERT_S_1 = TDM_ERT_S, 
      DLY_ERT_T_1 = TDM_ERT_T, 
      DLY_ERT_V_1 = TDM_ERT_V, 
      DLY_ERT_W_1 = TDM_ERT_W,
      DLY_ERT_NA_1 = TDM_ERT_NA,
      FLT_ERT_1_DLY = TDF_ERT,
      FLT_ERT_1_DLY_15 = TDF_15_ERT
    )
  
  
  t_country <- con |> 
    tbl("V_PRU_REL_COUNTRY_ZONE") |> 
    filter(ZONE_ID == 58L) |> 
    select(COUNTRY_ICAO_CODE)
  
  
  t3 <- t_base |> 
    filter(
      UNIT_PRU_TYPE == 'COUNTRY_FIR',
      (UNIT_CODE %in% sql('(select country_icao_code from V_PRU_REL_COUNTRY_ZONE where zone_id = 58)') || UNIT_CODE %in% c('EG_CT', 'EG_OC', 'LEGC', 'LP_CT', 'LP_OC')),
      !UNIT_NAME %in% c('Ukraine'),
      to_date('2015-01-01', 'YYYY-MM-DD') <= ENTRY_DATE
    ) |> 
    mutate(
      YEAR = year(ENTRY_DATE),
      MONTH_NUM = month(ENTRY_DATE),
      MONTH_MON = sql("TO_CHAR(ENTRY_DATE, 'MON')"),
      ENTITY_TYPE = 'COUNTRY (FIR)',
      ENTITY_NAME = UNIT_NAME,
      NULL
    ) |> 
    select(
      YEAR,
      MONTH_NUM,
      MONTH_MON,
      FLT_DATE = ENTRY_DATE,
      ENTITY_NAME,
      ENTITY_TYPE,
      FLT_ERT_1 = TTF_FLT,
      DLY_ERT_1 = TDM_ERT,
      DLY_ERT_A_1 = TDM_ERT_A, 
      DLY_ERT_C_1 = TDM_ERT_C, 
      DLY_ERT_D_1 = TDM_ERT_D, 
      DLY_ERT_E_1 = TDM_ERT_E,
      DLY_ERT_G_1 = TDM_ERT_G, 
      DLY_ERT_I_1 = TDM_ERT_I, 
      DLY_ERT_M_1 = TDM_ERT_M, 
      DLY_ERT_N_1 = TDM_ERT_N, 
      DLY_ERT_O_1 = TDM_ERT_O,
      DLY_ERT_P_1 = TDM_ERT_P, 
      DLY_ERT_R_1 = TDM_ERT_R, 
      DLY_ERT_S_1 = TDM_ERT_S, 
      DLY_ERT_T_1 = TDM_ERT_T, 
      DLY_ERT_V_1 = TDM_ERT_V, 
      DLY_ERT_W_1 = TDM_ERT_W,
      DLY_ERT_NA_1 = TDM_ERT_NA,
      FLT_ERT_1_DLY = TDF_ERT,
      FLT_ERT_1_DLY_15 = TDF_15_ERT
    )
  
  
  
  df_fir <- t1 |>
    union_all(t2) |>
    union_all(t3) |>
    collect()
  
  df_fir
}





if (type == "ansp") {
  data <- extract_dly_ansp(con, wef, til)
} else if (type == "fir") {
  data <- extract_dly_fir(con, wef, til)
} else {
  cat("Error: invalida TYPE,", type)
  q(status = -1)
}

data <- data |> 
  mutate(
    YEAR = as.integer(YEAR),
    MONTH_NUM = as.integer(MONTH_NUM),
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
  ) |> 
  arrange(FLT_DATE, ENTITY_NAME)


DBI::dbDisconnect(con)

mySave <- function(df, ftype) {
  y <- unique(df$YEAR)
  write_csv(df,
            file = paste0(out_dir, "/", str_c("ert_dly_", ftype, "_", y, ".csv.bz2")),
            na = "")
  df
}

# use purrr::partial to pass ftype
s <- partial(mySave, ftype = type)

# one file per YEAR
data %>% group_by(YEAR) %>% do(s(.))
