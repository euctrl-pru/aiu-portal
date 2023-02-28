#!/usr/bin/env Rscript

"Export to CSV file a full year of daily Traffic Complexity data.

The filename is 'traffic-complexity_YEAR.csv'.

Usage: export_tc_daily [-h] YEAR TABLE

-h --help             show this help text

Arguments:
YEAR  the YEAR to export
TABLE the database TABLE to use (we have one for each BADA version used, i.e. AUA_COMPLEXITY_3_15)

" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)


suppressMessages(library(lubridate))
suppressMessages(library(purrr))

usr <- Sys.getenv("PRU_CPLX_USR")
pwd <- Sys.getenv("PRU_CPLX_PWD")
dbn <- Sys.getenv("PRU_CPLX_DBNAME")
tbl <- "AUA_COMPLEXITY_3_15"

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_CPLX_USR")
  q(status = -1)
}

suppressMessages(library('ROracle'))
suppressMessages(library(stringr))
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(logger))


# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UDT"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

drv <- dbDriver("Oracle")
con <- dbConnect(drv, usr, pwd, dbname = dbn)

# read data, use Date (not DateTime)
# •	FL 		Flight Level
# •	Time	Time of the day (per hour calculation only)
# •	FT 		Flight hours
# •	FD: 	Flight distance in the cell
# •	DH: 	Vertical distance in the cell
# •	TX 		Hours of interactions
# •	TXH 	Hours of horizontal interactions
# •	TXV 	Hours of vertical interactions
# •	TXS: 	Hours of speed interactions.
# •	N  		Number of flight collected within the ACC
# •	NCELL Number of cell within the ACC
# For the database output, the following columns are also available:
# •	CPLX_DATE	  Day used to compute the complexity
# •	SOURCE		  Module used to compute the complexity. Ex: PRU 1.1
# •	LAST_UPDATE	Day when the computation has been launched


sqlq <- str_glue(
  "SELECT * FROM {TABLE} WHERE TO_CHAR(CPLX_DATE, 'YYYY') = ?YEAR",
  TABLE = opts$TABLE)
query <- sqlInterpolate(con, sqlq, YEAR = opts$YEAR)
logger::log_debug('Oracle query = {query}')

flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  mutate(cplx_date = as.Date(cplx_date)) %>% 
  write_csv(str_c("traffic-complexity_", opts$YEAR, ".csv"), na = "", col_names = TRUE)
