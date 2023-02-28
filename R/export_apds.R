#!/usr/bin/env Rscript

"Export APDS data to CSV files.

Usage: export_apds [-h] WEF TIL

-h --help             show this help text

Arguments:
WEF  date from when to export data, format YYYY-MM-DD
TIL  date till when to export data, format YYYY-MM-DD (non-inclusive)
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)


suppressMessages(library(lubridate))
suppressMessages(library(purrr))

safe_ymd <- safely(ymd)
wef <- safe_ymd(opts$WEF, quiet = TRUE)
til <- safe_ymd(opts$TIL, quiet = TRUE)

if (is.null(wef$result) || is.null(til$result)) {
  cat("Error: invalid WEF and/or TIL, it must be in YYYY-MM-DD format", "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  wef <- format(wef$result, "%Y-%m-%d")
  til <- format(til$result, "%Y-%m-%d")
}

usr <- Sys.getenv("PRU_ATMAP_USR")
pwd <- Sys.getenv("PRU_ATMAP_PWD")
dbn <- Sys.getenv("PRU_ATMAP_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_ATMAP_USR")
  q(status = -1)
}

suppressMessages(library('ROracle'))
suppressMessages(library(stringr))
suppressMessages(library(dplyr))
suppressMessages(library(readr))


# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UDT"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

drv <- dbDriver("Oracle")


con <- dbConnect(drv, usr, pwd, dbname = dbn)

sqlq <- "SELECT
  *
FROM
  SWH_FCT.FAC_APDS_FLIGHT_IR691
WHERE
      MVT_TIME_UTC >= TO_DATE(?WEF, 'YYYY-MM-DD')
  AND MVT_TIME_UTC <  TO_DATE(?TIL, 'YYYY-MM-DD')
  AND SRC_DATE_FROM >= TO_DATE(?WEF, 'YYYY-MM-DD')
  AND SRC_DATE_FROM <  TO_DATE(?TIL, 'YYYY-MM-DD')
--  AND SRC_DATE_FROM = TRUNC(MVT_TIME_UTC, 'MONTH')
"

query <- sqlInterpolate(con, sqlq, WEF = wef, TIL = til)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>% as_tibble() %>% 
  select(
    APDS_ID, 
    AP_C_FLTID,
    AP_C_FLTRUL,
    AP_C_REG,
    ends_with("ICAO"),
    SRC_PHASE,
    MVT_TIME_UTC,
    BLOCK_TIME_UTC,
    SCHED_TIME_UTC,
    ARCTYP,
    AP_C_RWY,
    AP_C_STND,
    starts_with("C40_"),
    starts_with("C100_")
  ) %>% 
  select(
    -ends_with("_MIN"),
    -ends_with("_IN_FRONT"),
    -ends_with("_CTFM"),
    -ends_with("_CPF"),
    -contains("TRANSIT"))

write_csv(
  data,
  str_c("FAC_APDS_FLIGHT_IR691_",
    wef,
    "_",
    til,
    ".csv.bz2"),
  na = "",
  col_names = TRUE)
