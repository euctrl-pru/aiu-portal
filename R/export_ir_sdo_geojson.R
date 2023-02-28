#!/usr/bin/env Rscript

"Export EAD SDO IRs (Information Regions) to GeoJSON file.

Usage: export_ir_sdo_geojson [-h] [-o FILE]

  -o FILE, --output FILE   name of output GeoJSON file [default: ir-sdo.geojson]
  -h --help                show this help text

" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

usr <- Sys.getenv("PRU_SDE_USR")
pwd <- Sys.getenv("PRU_SDE_PWD")
dbn <- Sys.getenv("PRU_SDE_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_SDE_USR")
  q(status = -1)
}

suppressMessages(library('ROracle'))
suppressMessages(library(stringr))
suppressMessages(library(dplyr))
suppressMessages(library(readr))
suppressMessages(library(sf))


# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UDT"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

drv <- dbDriver("Oracle")
con <- dbConnect(drv, usr, pwd, dbname = dbn)

sqlq <- "WITH sdo
AS
(
SELECT
  sdo_geometry(replace(replace(sde.st_astext(tab.shape), ' 0.00000000 nan', ''), ' ZM', '')) sdo_shape,
  tab.*
FROM PrismeAIS.AIRSPACE tab
) 
SELECT '{ \"type\": \"FeatureCollection\", \"features\": [' ||
rtrim(PRU_SDE.clobagg('{ \"type\": \"Feature\", \"geometry\": '
|| PRU_SDE.SDO2GEOJSON(A.sdo_shape,3,0,0)
|| ', \"properties\": {'
|| '\"ID\": \"'                || A.IDENT_TXT          || '\", '
|| '\"MIN_FL\": '              || A.CALC_LOWER_FL      || ', '
|| '\"MAX_FL\": '              || A.CALC_UPPER_FL      || ', '
|| '\"NAME\": \"'              || A.NAME_TXT           || '\", '
|| '\"ICAO\": \"'              || A.ICAO_TXT           || '\", '
|| '\"TYPE\": \"'              || A.TYPE_CODE          || '\"'
|| '}}' || ',' || chr(13)),',' || chr(13)) || ']}'
FROM sdo A
WHERE
    A.TYPE_CODE IN ( 'FIR' , 'UIR' )
    AND A.LEVEL_CODE IN ( 'B' , 'L', 'U' )
    AND A.sdo_shape IS NOT NULL
"
query <- sqlq
# query <- DBI::sqlInterpolate(con, sqlq, CFMU_AIRAC = cfmu_airac)
flt <- DBI::dbSendQuery(con, query)
data <- DBI::fetch(flt, n = -1) 

DBI::dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>%
  dplyr::first() %>%
  st_read() %>% 
  # save as GeoJSON
  st_write(opts$output, driver = "GeoJSON", delete_dsn = TRUE, quiet = TRUE)
