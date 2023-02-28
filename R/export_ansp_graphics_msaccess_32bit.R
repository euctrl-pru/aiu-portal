# TO BE RUN by R 32-bits
# THIS crashes R session!!!! DUE TO CELLS CONTAINING wORD DOCS

library(dplyr)
library(stringr)
library(lubridate)
library(readr)
library(RODBC)
library(here)

# as from July use YYYY - 2 for the relevant Access file
tdy <- today()
yyyy <- tdy %>% year()

year <- ifelse(tdy %>% month() >= 7, yyyy - 2, yyyy - 3)

ace_graphics <- str_glue(
  "G:/HQ/dgof-pru/Data/Application/Ace/ACE\ Factsheet/{year}/Database/ACE_graphic.mdb",
  year = year)
con <- odbcConnectAccess2007(ace_graphics)

cat("Fetching Tbl_ACE_Graphics...")
# THIS crashes R session!!!!
sqlFetch(con, "Tbl_ACE_Graphics", as.is = FALSE, stringsAsFactors = FALSE) %>%
  as_tibble() %>%
  write_rds(here("data-config", "tbl-graphics.rds"))
cat("Fetching Tbl_ACE_Graphics...done.")

odbcClose(con)
