#!/usr/bin/env Rscript

"Export FR24 traffic to CSV files.

Usage: export_fr24 [-h] [-t TYPE] WEF TIL

-h --help             show this help text
-t TYPE, --type=TYPE  the TYPE of entity; one of flight, point [default: flight]

Arguments:
  WEF  date from when to export data, format YYYY-MM-DD
  TIL  date till when to export data, format YYYY-MM-DD (non-inclusive)
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

types <- c("flight", "point")

if (!(opts$type %in% types)) {
  cat("Error: incorrect TYPE, it must be one of", paste0(types, collapse = ", "), "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  type <- opts$type
}

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

usr <- Sys.getenv("PRU_FR24_USR")
pwd <- Sys.getenv("PRU_FR24_PWD")
dbn <- Sys.getenv("PRU_FR24_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_FR24_USR")
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

host <- "porape7"
port <- 1534
svc <- "fr24_live"

connect.string <- paste(
  "(DESCRIPTION=",
  "(ADDRESS=(PROTOCOL=tcp)(HOST=", host, ")(PORT=", port, "))",
  "(CONNECT_DATA=(SERVICE_NAME=", svc, ")))", sep = "")

con <- dbConnect(drv, usr, pwd, dbname = connect.string)

sqlq_point <- "SELECT
  FLIGHT_ID, 
  LAT,
  LON,
  TRACK_GND,
  ALT,
  SPEED,
  SQUAWK,
  RADAR_ID,
  EVENT_TIME,
  ON_GROUND,
  VERT_SPEED,
  ALT_FMS,
  ALT_MCP,
  AUTOPILOT,
  IAS,
  MACH,
  QNH,
  TAS,
  TEMP,
  TRACK,
  WIND_DIR,
  WIND_SPEED,
  ALT_GPS,
  CATEGORY,
  PRECISION,
  SOURCE    
FROM
  FR24_ADSB_DATA_POINTS
WHERE
  EVENT_TIME     >= TO_DATE(?WEF, 'YYYY-MM-DD')
  AND EVENT_TIME <  TO_DATE(?TIL, 'YYYY-MM-DD')
"


sqlq_flight <- "SELECT
  FLIGHT_ID,
  START_TIME,
  ADEP,
  ADES,
  CALLSIGN,
  FLIGHT,
  REG,
  MODEL,
  ADDRESS
FROM
  FR24_ADSB_DATA_FLIGHTS
WHERE
  START_TIME     >= TO_DATE(?WEF, 'YYYY-MM-DD')
  AND START_TIME <  TO_DATE(?TIL, 'YYYY-MM-DD')
"

if (type == "point") {
  sqlq <- sqlq_point
} else if (type == "flight") {
  sqlq <- sqlq_flight
} else {
  cat("Error: invalida TYPE,", type)
  q(status = -1)
}

query <- sqlInterpolate(con, sqlq, WEF = wef, TIL = til)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")



mySave <- function(df, ftype, wef) {
  write_csv(
    df,str_c(
      "FR24_ADSB_DATA_",
      toupper(ftype),
      "S_",
      wef,
      ".csv.bz2"), na = "")
}

mySave(data, type, wef)