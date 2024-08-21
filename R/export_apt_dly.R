#!/usr/bin/env Rscript

"Export to CSV daily airport arrival ATFM delays.

Usage: export_apt_dly [-h] [-o DIR] WEF TIL

  -h --help             show this help text
  -o DIR                directory where to save the output [default: .]

Arguments:
  WEF  date from when to export data, format YYYY-MM-DD
  TIL  date till when to export data, format YYYY-MM-DD (non-inclusive)
" -> doc

suppressWarnings(suppressMessages(library(docopt)))

# retrieve the command-line arguments
opts <- docopt(doc)

suppressWarnings(suppressMessages(library(lubridate)))
suppressWarnings(suppressMessages(library('ROracle')))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))
suppressWarnings(suppressMessages(library(purrr)))
suppressWarnings(suppressMessages(library(fs)))

wef <- ymd(opts$WEF, quiet = TRUE)
til <- ymd(opts$TIL, quiet = TRUE)

out_dir <- opts$o


if (is.na(wef) || is.na(til)) {
  cat("Error: invalid WEF and/or TIL, it must be in YYYY-MM-DD format", "\n")
  q(status = -1)
} else {
  wef <- format(wef, "%Y-%m-%d")
  til <- format(til, "%Y-%m-%d")
}

if (!fs::dir_exists(out_dir)) {
  cat("Error: non-existing DIR", "\n")
  cat(doc, "\n")
  q(status = -1)
}

out_dir <- fs::path_abs(out_dir)


usr <- Sys.getenv("PRU_DEV_USR")
pwd <- Sys.getenv("PRU_DEV_PWD")
dbn <- Sys.getenv("PRU_DEV_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_DEV_USR")
  q(status = -1)
}


# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UDT"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

drv <- dbDriver("Oracle")
con <- dbConnect(drv, usr, pwd, dbname = dbn)

query <- "
SELECT  
to_char(FLIGHT_DATE,'YYYY') as YEAR, 
EXTRACT (MONTH FROM FLIGHT_DATE) MONTH_NUM,   
to_char(FLIGHT_DATE,'MON') as MONTH_MON, 
FLIGHT_DATE as FLT_DATE,    
ARP_CODE as APT_ICAO, 
PRU_APT_NAME as APT_NAME, 
CASE PRU_STATE_NAME WHEN 'Turkey' THEN 'Türkiye' ELSE PRU_STATE_NAME END STATE_NAME, 
--PRU_STATE_NAME as STATE_NAME,   
TTF_ARR as FLT_ARR_1, 
TDM_ARP_ARR as DLY_APT_ARR_1, 
TDM_ARP_ARR_A as DLY_APT_ARR_A_1,  
TDM_ARP_ARR_C as DLY_APT_ARR_C_1,  
TDM_ARP_ARR_D as DLY_APT_ARR_D_1,  
TDM_ARP_ARR_E as DLY_APT_ARR_E_1, 
TDM_ARP_ARR_G as DLY_APT_ARR_G_1,  
TDM_ARP_ARR_I as DLY_APT_ARR_I_1,  
TDM_ARP_ARR_M as DLY_APT_ARR_M_1,  
TDM_ARP_ARR_N as DLY_APT_ARR_N_1,  
TDM_ARP_ARR_O as DLY_APT_ARR_O_1, 
TDM_ARP_ARR_P as DLY_APT_ARR_P_1,  
TDM_ARP_ARR_R as DLY_APT_ARR_R_1,  
TDM_ARP_ARR_S as DLY_APT_ARR_S_1,  
TDM_ARP_ARR_T as DLY_APT_ARR_T_1,  
TDM_ARP_ARR_V as DLY_APT_ARR_V_1,  
TDM_ARP_ARR_W as DLY_APT_ARR_W_1, 
TDM_ARP_ARR_NA as DLY_APT_ARR_NA_1, 
TDF_ARP_ARR as FLT_ARR_1_DLY, 
TDF_15_ARP_ARR as FLT_ARR_1_DLY_15, 
ATFM_Version 
--CASE WHEN FLIGHT_DATE<'04-APR-2016' THEN 'v1' ELSE 'v1' END as Version  
FROM PRUDEV.V_PRU_FAC_TDC_ARP_ARR_DD a, PRUDEV.DSH_REL_AIRPORT_COUNTRY b 
WHERE FLIGHT_DATE >= TO_DATE(?WEF, 'YYYY-MM-DD') and FLIGHT_DATE < TO_DATE(?TIL, 'YYYY-MM-DD')
AND a.ARP_code = b.APT_ICAO 
AND ARP_CODE IN (SELECT APT_ICAO FROM PRUDEV.DSH_REL_AIRPORT_COUNTRY) 
AND PRU_STATE_NAME not in ('Ukraine') 
order by 4 
"


alt_query <- "
  WITH
    DATES AS (
      SELECT
        TO_DATE(?WEF, 'YYYY-MM-DD')       AS START_DATE,
        TO_DATE(?TIL, 'YYYY-MM-DD')       AS END_DATE_INC,
        TO_DATE('04-APR-16', 'DD-MON-RR') AS END_V1
      FROM DUAL
    ),
    DAYS_IN_PERIOD AS (
      SELECT
        START_DATE + INTERVAL '1' DAY * (LEVEL - 1) AS DAY_IN
      FROM DUAL, DATES
      CONNECT BY START_DATE + INTERVAL '1' DAY * (LEVEL - 1) < END_DATE_INC
    )
  SELECT
    EXTRACT(YEAR FROM DAY_IN)  AS YEAR,
    EXTRACT(MONTH FROM DAY_IN) AS MONTH_NUM,
    TO_CHAR(DAY_IN, 'MON')     AS MONTH_MON,
    DAY_IN,
    R.*
  FROM
    DAYS_IN_PERIOD
  CROSS JOIN LATERAL (
    SELECT
      APT_ICAO,
      PRU_APT_NAME                      AS APT_NAME,
      CASE PRU_STATE_NAME WHEN 'Turkey' THEN 'Türkiye' ELSE PRU_STATE_NAME END STATE_NAME,
      NVL(T.FLIGHT_DATE, D.FLIGHT_DATE) AS FLT_DATE,
      NVL(TTF_ARR, 0)                   AS FLT_ARR_1,
      NVL(TDM_ARP_ARR, 0)               AS DLY_APT_ARR_1,
      NVL(TDM_ARP_ARR_A, 0)             AS DLY_APT_ARR_A_1,
      NVL(TDM_ARP_ARR_C, 0)             AS DLY_APT_ARR_C_1,
      NVL(TDM_ARP_ARR_D, 0)             AS DLY_APT_ARR_D_1,
      NVL(TDM_ARP_ARR_E, 0)             AS DLY_APT_ARR_E_1,
      NVL(TDM_ARP_ARR_G, 0)             AS DLY_APT_ARR_G_1,
      NVL(TDM_ARP_ARR_I, 0)             AS DLY_APT_ARR_I_1,
      NVL(TDM_ARP_ARR_M, 0)             AS DLY_APT_ARR_M_1,
      NVL(TDM_ARP_ARR_N, 0)             AS DLY_APT_ARR_N_1,
      NVL(TDM_ARP_ARR_O, 0)             AS DLY_APT_ARR_O_1,
      NVL(TDM_ARP_ARR_P, 0)             AS DLY_APT_ARR_P_1,
      NVL(TDM_ARP_ARR_R, 0)             AS DLY_APT_ARR_R_1,
      NVL(TDM_ARP_ARR_S, 0)             AS DLY_APT_ARR_S_1,
      NVL(TDM_ARP_ARR_T, 0)             AS DLY_APT_ARR_T_1,
      NVL(TDM_ARP_ARR_V,0)              AS DLY_APT_ARR_V_1,
      NVL(TDM_ARP_ARR_W ,0)             AS DLY_APT_ARR_W_1,
      NVL(TDM_ARP_ARR_NA ,0)            AS DLY_APT_ARR_NA_1,
      NVL(TDF_ARP_ARR, 0)               AS FLT_ARR_1_DLY,
      NVL(TDF_15_ARP_ARR, 0)            AS FLT_ARR_1_DLY_15,
      CASE WHEN T.FLIGHT_DATE < (SELECT END_V1 FROM DATES) THEN 'v1' ELSE 'v2' END AS ATFM_VERSION
  FROM
    PRUDEV.DSH_REL_AIRPORT_COUNTRY B
  LEFT JOIN PRUDEV.V_PRU_FAC_T_ARP_ARR_DD T
     ON (T.ARP_CODE = B.APT_ICAO
     AND T.FLIGHT_DATE = DAY_IN)
  LEFT JOIN PRUDEV.V_PRU_FAC_DC_ARP_ARR_DD D
     ON (D.ARP_CODE = B.APT_ICAO
     AND D.FLIGHT_DATE = DAY_IN)
  WHERE B.PRU_STATE_NAME <> 'Ukraine') R
  WHERE FLT_DATE IS NOT NULL
  "

# NOTE: use alternative query!
sqlq <- alt_query

query <- sqlInterpolate(con, sqlq, WEF = wef, TIL = til)
print(query)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

DBI::dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

s <- function(df) {
  y <- unique(df$YEAR)
  write_csv(df, paste0(out_dir, "/", stringr::str_c("apt_dly_", y, ".csv.bz2")), na = "")
  df
}


data %>% 
  # for GG new query
  select(-DAY_IN) %>%
  group_by(YEAR) %>% 
  do(s(.))
