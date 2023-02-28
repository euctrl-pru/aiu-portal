#!/usr/bin/env Rscript

"Export ES (Elementary Airspace) to GeoJSON file.

Usage: export-es-geojson [-h] [-o FILE] <cfmu_airac>

  -o FILE, --output FILE   name of output GeoJSON file [default: es-<cfmu_airac>.geojson]
  -h --help                show this help text

Arguments:
    <cfmu_airac>  the AIRAC number (CFMU format)
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

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
suppressMessages(library(sf))

cfmu_airac <- opts$cfmu_airac
opts$output <- str_replace(opts$output, "<cfmu_airac>", cfmu_airac)
opts["--output"] <- opts$output


# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UDT"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

drv <- dbDriver("Oracle")
con <- dbConnect(drv, usr, pwd, dbname = 'porape5')

sqlq <- "WITH
AIRSPACE_NAMES
AS
(
  SELECT DISTINCT AIRSPACE_ID, AIRSPACE_TYPE, NAME, CODE
  FROM ENV_SP.AIRSPACE A, PRU_CFMU_ES P
  WHERE
  A.AIRSPACE_ID = P.ID
  AND A.AIRSPACE_KIND = 'ES'
  AND AC_ID = ?CFMU_AIRAC
)
SELECT '{ \"type\": \"FeatureCollection\", \"features\": [' ||
rtrim(SWH_MAP.clobagg('{ \"type\": \"Feature\", \"geometry\": '
|| SWH_MAP.SDO2GEOJSON(SHAPE,3,0,0)
|| ', \"properties\": {'
|| '\"AC_ID\": '               || A.AC_ID                 || ', '
|| '\"AV_AIRSPACE_ID\": \"'    || A.AIRSPACE_ID           || '\", '
|| '\"MIN_FLIGHT_LEVEL\": '    || A.MIN_FLIGHT_LEVEL      || ', '
|| '\"MAX_FLIGHT_LEVEL\": '    || A.MAX_FLIGHT_LEVEL      || ', '
|| '\"NAME\": \"'              || AIRSPACE_NAMES.NAME     || '\", '
|| '\"CODE\": \"'              || AIRSPACE_NAMES.CODE     || '\", '
|| '\"AIRSPACE_TYPE\": \"'     || A.AIRSPACE_TYPE         || '\"'
|| '}}' || ',' || chr(13)),',' || chr(13)) || ']}'
FROM ENV_SP.AIRSPACE A
LEFT JOIN AIRSPACE_NAMES
ON 
  A.AIRSPACE_ID = AIRSPACE_NAMES.AIRSPACE_ID
  AND A.AIRSPACE_TYPE = AIRSPACE_NAMES.AIRSPACE_TYPE
WHERE
  A.AC_ID = ?CFMU_AIRAC
  AND A.AIRSPACE_TYPE = 'ES'
  AND A.SHAPE IS NOT NULL
"


query <- DBI::sqlInterpolate(con, sqlq, CFMU_AIRAC = cfmu_airac)
flt <- DBI::dbSendQuery(con, query)
data <- DBI::fetch(flt, n = -1) 

DBI::dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data %>%
  dplyr::first() %>%
  st_read() %>% 
  # save as GeoJSON
  st_write(opts$output, driver = "GeoJSON", delete_dsn = TRUE)
