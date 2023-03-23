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

sqlq <- "SELECT 
to_char(FLIGHT_DATE,'YYYY') as YEAR,
EXTRACT (MONTH FROM FLIGHT_DATE) MONTH_NUM,  
to_char(FLIGHT_DATE,'MON') as MONTH_MON,
FLIGHT_DATE as FLT_DATE,   
ARP_CODE as APT_ICAO,
PRU_APT_NAME as APT_NAME, 
PRU_State_NAME as STATE_NAME,  
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
FROM PRUDEV.V_PRU_FAC_TDC_ARP_ARR_DD a, PRUDEV.DSH_REL_AIRPORT_COUNTRY b
WHERE FLIGHT_DATE >= TO_DATE(?WEF, 'YYYY-MM-DD') and FLIGHT_DATE < TO_DATE(?TIL, 'YYYY-MM-DD')
AND a.ARP_code = b.apt_icao
AND ARP_CODE IN (SELECT apt_icao FROM PRUDEV.DSH_REL_AIRPORT_COUNTRY)
AND PRU_State_NAME not in ('Ukraine')
order by 4
"


query <- sqlInterpolate(con, sqlq, WEF = wef, TIL = til)
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
  group_by(YEAR) %>% 
  do(s(.))
