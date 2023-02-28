#!/usr/bin/env Rscript

"Export to CSV the ANSP composition in terms of AUA's.

Two files are generated:
* the first in 'data-config' directory called 'ansp-composition.csv'.
  It containes all AUAs per ANSP
* the second in 'data' directory called 'date-ansp-composition.yml'.
  It contains the date the above data have been extracted

Usage: export_ansp_composition [-h] DATE

  -h --help             show this help text

Arguments:
  DATE  the date, in YYYY-MM-DD format, when the ANSP composition is extracted for.
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

suppressMessages(library(lubridate))

instant <- ymd(opts$DATE, quiet = TRUE)


if (is.na(instant)) {
  cat("Error: invalid DATE, it must be in YYYY-MM-DD format", "\n")
  q(status = -1)
} else {
  instant <- format(instant, "%Y-%m-%d")
}

usr <- Sys.getenv("PRU_DEV_USR")
pwd <- Sys.getenv("PRU_DEV_PWD")
dbn <- Sys.getenv("PRU_DEV_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_DEV_USR")
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

sqlq <- "SELECT ANSP_NAME, PRU_ATC_TYPE, AUA_CODE, AUA_NAME
FROM
  PRUDEV.V_PRU_REL_CFMU_AUA_ANSP
WHERE
  (WEF <= TO_DATE(?INSTANT, 'YYYY-MM-DD') AND TILL >= TO_DATE(?INSTANT, 'YYYY-MM-DD')) AND
  ANSP_NAME NOT IN (
    'MILITARY',
    'UNKNOWN',
    'AIRPORT',
    'BHANSA',
    'Avinor (Continental)',
    'Avinor (Oceanic)',
    'HungaroControl',
    'KFOR (HungaroControl)',
    'NATS',
    'NATS (Oceanic)',
    'NAV Portugal (Santa Maria)',
    'Israel AA',
    'ONDA'
  )
ORDER BY LOWER(AUA_CODE), PRU_ATC_TYPE
"


query <- sqlInterpolate(con, sqlq, INSTANT = instant)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>%
  as_tibble() %>%
  write_csv(file = here::here("data-config", "ansp-composition.csv"), na = "")

cat("date:", instant, file = here::here("data", "date-ansp-composition.yml"))
