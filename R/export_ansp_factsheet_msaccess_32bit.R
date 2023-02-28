# TO BE RUN by R 32-bits

# See generate-ansp-factsheets.R

library(dplyr)
library(stringr)
library(lubridate)
library(readr)
library(RODBC)
library(here)

# as from July use YYYY - 2 for the relevant Access file
tdy <- today()
yyyy <- tdy %>% year()

year <- ifelse(tdy %>% month() >= 6, yyyy - 2, yyyy - 3)

ace_factsheet <- str_glue(
  "G:/HQ/dgof-pru/Data/Application/Ace/ACE_Database/ACE.mdb",
  # here::here("ACE_{year}_factsheet.mdb"),
  year = year)

DRIVERINFO <- "Driver={Microsoft Access Driver (*.mdb, *.accdb)};"
MDBPATH <- ace_factsheet
PATH <- paste0(DRIVERINFO, "DBQ=", MDBPATH)

con <- odbcDriverConnect(PATH)

cat("before fetching Tbl_ACE_Admin")
# sqlTables(con)
sqlFetch(con,"ANSP_Q_FACT_FACTSHEET", as.is = FALSE, stringsAsFactors = FALSE) %>%
  as_tibble() %>%
  write_rds(here("data-config", "ansp_q_facts.rds"))


odbcClose(con)
