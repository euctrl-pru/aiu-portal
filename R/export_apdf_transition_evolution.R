#!/usr/bin/env Rscript

"Export Airport Transition to IR390 data to CSV files.

Usage: export_apdf_transition_evolution [-h]

-h --help             show this help text

" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

usr <- Sys.getenv("PRU_ATMAP_USR")
pwd <- Sys.getenv("PRU_ATMAP_PWD")
dbn <- Sys.getenv("PRU_ATMAP_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_ATMAP_USR")
  q(status = -1)
}

suppressMessages(library('ROracle'))
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
C.PARAM_VALUE                                                                       AS AIRPORT,
INFO.APT_COUNTRY,
INFO.APT_NAME,
SUBSTR(E.PARAM_VALUE,1,4) || SUBSTR(E.PARAM_VALUE,6,2)                              AS DATE_FROM,
MIN(SUBSTR(T4266.BATCH_NAME,11,5))                                                  AS FORMAT
FROM    SWH_PSM.V_LOG_BATCH_EXEC T4266, 
SWH_PSM.LOG_JOB_EXEC B, 
SWH_PSM.LOG_JOB_EXEC_PARAM C,
SWH_PSM.LOG_JOB_EXEC D, 
SWH_PSM.LOG_JOB_EXEC_PARAM E,
PRU_AIRPORT.STAT_AIRPORT_INFO INFO 
WHERE (T4266.BATCH_NAME LIKE 'Load data IR390 ____ %' OR T4266.BATCH_NAME LIKE 'Load data IR691 ____ %')   
AND   B.LOG_BATCH_ID    = T4266.LOG_BATCH_ID 
AND   C.LOG_JOB_ID      = B.LOG_JOB_ID 
AND   C.PARAM_NAME IN ('AIRPORT')
AND   D.LOG_BATCH_ID    = T4266.LOG_BATCH_ID 
AND   E.LOG_JOB_ID      = D.LOG_JOB_ID 
AND   E.PARAM_NAME IN ('DATE_FROM')
AND C.PARAM_VALUE <> 'ALL'
AND NOT (C.PARAM_VALUE LIKE 'EN%' AND C.PARAM_VALUE NOT IN ('ENBR','ENGM','ENVA','ENZV'))
AND SUBSTR(E.PARAM_VALUE,1,4) || SUBSTR(E.PARAM_VALUE,6,2) >= '201501'
AND INFO.AIRPORT(+) = C.PARAM_VALUE   
GROUP BY C.PARAM_VALUE, SUBSTR(E.PARAM_VALUE,1,4) || SUBSTR(E.PARAM_VALUE,6,2), INFO.APT_COUNTRY, INFO.APT_NAME
ORDER BY C.PARAM_VALUE, SUBSTR(E.PARAM_VALUE,1,4) || SUBSTR(E.PARAM_VALUE,6,2)"

query <- sqlInterpolate(con, sqlq)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>% as_tibble()

write_csv(
  data,
  here::here("data-config", "apdf-transition-IR691.csv"),
  na = "",
  col_names = TRUE)
