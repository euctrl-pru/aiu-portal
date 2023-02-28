#!/usr/bin/env Rscript

"Export APT data to CSV files.

The range [WEF, TIL)] is used to find the airports that exit within the full time interval.

Usage: export_apt [-h] WEF TIL

-h --help             show this help text

Arguments:
WEF  date from when the airport is valid, format YYYY-MM-DD
TIL  date till when the airport is valid, format YYYY-MM-DD (non-inclusive)

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
EC_AP_CODE,
EC_AP_NAME,
ICAO_AP_CODE,
ICAO_AP_NAME,
IATA_AP_CODE,
IATA_AP_NAME,
LONGITUDE,
LATITUDE,
ISO_CT_CODE,
ISO_CT_NAME,
VALID_FROM,
VALID_TO
FROM
SWH_FCT.DIM_AIRPORT
WHERE
VALID_FROM <= TO_DATE(?WEF, 'YYYY-MM-DD')
AND VALID_TO > TO_DATE(?TIL, 'YYYY-MM-DD')
"

query <- sqlInterpolate(con, sqlq, WEF = wef, TIL = til)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>% as_tibble()

write_csv(
  data,
  str_c("SWH_FCT_DIM_AIRPORT_",
    wef,
    "_",
    til,
    ".csv.bz2"),
  na = "",
  col_names = TRUE)
