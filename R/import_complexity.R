#!/usr/bin/env Rscript

"Save Traffic Complexity indicator values to DB.

Usage:
  import_complexity -h
  import_complexity [-b BADA] [-s VER] [-u UPDATE] [-d DIR] -t TABLE FILENAME...


Options:
  -h --help  show this help text
  -b BADA    the BADA version used [default: 3.14-201810]
  -d DIR     the directory where CSV FILENAME are located [default: ./]
  -s VER     the PRU Complexity program version [default: PRU 1.3]
  -t TABLE   the DB table where to append the data
  -u UPDATE  the date (YYYY-MM-DD) of the upload to DB [default: today]

Arguments:
  FILENAME  the Trafic Complexity indicator CSV file to upload to DB.
            It is assumed to contain the date of the calculation,
            i.e. complexity_20190331_BADA313.csv refers to 2019-03-31
" -> doc

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(docopt))))

# retrieve the command-line arguments
opts <- docopt(doc)

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(lubridate))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(purrr))))

safe_ymd <- safely(ymd)

if (opts["u"] == "today") {
  ud <- lubridate::today()
} else {
  ud <- safe_ymd(opts["u"])
  if (is.null(ud$result)) {
    cat("Error: invalid UPDATE date, it must be a valid date in YYYY-MM-DD format", "\n")
    cat(doc, "\n")
    q(status = -1)
  } else {
    ud <- ud$result
  }
}

usr <- Sys.getenv("PRU_CPLX_USR")
pwd <- Sys.getenv("PRU_CPLX_PWD")
dbn <- Sys.getenv("PRU_CPLX_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_CPLX_USR")
  q(status = -1)
}

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(ROracle))))

drv <- DBI::dbDriver("Oracle")


# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UTC"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

con <- ROracle::dbConnect(drv, usr, pwd, dbname = dbn)

suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(stringr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(dplyr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(readr))))
suppressMessages(suppressWarnings(suppressPackageStartupMessages(library(vroom))))


read_complexity <- function(filename, dirname, update_date, bada_ver, sw_ver) {
  day <- (stringr::str_split(fs::path_file(filename), "_")[[1]])[2] %>% lubridate::as_date()
  cs <- c("UNIT_CODE", "FL", "FT", "FD", "DH", "TX", "TXH", "TXV", "TXS", "N", "NCELL")
  cols <- cols(
    .default  = col_character(),
    "UNIT_CODE" = col_character(),
    "FL"        = col_integer(),
    "FT"        = col_double(),
    "FD"        = col_integer(),
    "DH"        = col_integer(),
    "TX"        = col_double(),
    "TXH"       = col_double(),
    "TXV"       = col_double(),
    "TXS"       = col_double(),
    "N"         = col_integer(),
    "NCELL"     = col_integer()
  )
  data <- vroom::vroom(
    str_glue("{dir}/{file}", dir = dirname, file = filename),
    # delim = "\t",
    col_select = cs,
    col_types = cols) %>%
    # drop last column, i.e. the one after NCELL which is there just because there is an extra TAB
    select(-starts_with("...")) %>%
    mutate(
      CPLX_DATE = day,
      SOURCE = sw_ver,
      LAST_UPDATE = update_date,
      BADA_VERSION = bada_ver
    ) %>%
    select(UNIT_CODE, CPLX_DATE, everything())
}

read <- partial(read_complexity,
                dirname = opts$d,
                update_date = ud,
                bada_ver = opts$b,
                sw_ver = opts$s)
ci <- map_dfr(opts$FILENAME, read)
r <- ROracle::dbWriteTable(
  con,
  opts$t,
  value = ci,
  append = TRUE,
  date = TRUE)

r <- dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")


