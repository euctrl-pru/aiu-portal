#
# Generate a CSV file, 'traffic_complexity.csv', for bulk append to the DB table
# 
# Then use import_traffic_complexity.bat/.sh to import to DB via SQLLoader
#
# Assumptions:
#
# * the second field of the filename (separated by '_' ) is the day the TC is calculated for,
#    i.e. '20181231' in 'complexity_20181231_bada_3_15_201912.csv'
#
library(lubridate)
library(stringr)
library(fs)
library(dplyr)
library(readr)
library(purrr)


base_dir    <- "G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Output"

# NOTE: CHANGE HERE *********************************************
files_regex <- "complexity_20201.*_bada_3_15_201912.csv"

# ...and HERE: version/... info
tbl  <- "AUA_COMPLEXITY_3_15"
bada <- "3_15_201912"
ver  <- "PRU 1.3 LAA"
upd  <- lubridate::now() %>% lubridate::as_date()
# ... or provide your own date 
# upd  <- lubridate::as_date("2020-01-30")
#****************************************************************


ifiles      <- fs::dir_ls(base_dir, regexp = files_regex)

read_traffic_complexity <- function(ifile, cols, upload_date, db_table, bada_ver, sw_ver) {
  dd <- (stringr::str_split(fs::path_file(ifile), "_")[[1]])[2] %>% lubridate::as_date()
  # read the file
  readr::read_tsv(ifile, col_types = cols) %>% 
    # Add bada and pruci version columns
    dplyr::mutate(CPLX_DATE    = dd,
                  BADA_VERSION = bada_ver,
                  SOURCE       = sw_ver,
                  LAST_UPDATE  = upload_date)
  
}

generate_tc_upload <- function(ifiles, upload_date = upd, db_table = tbl, bada_ver = bada, sw_ver = ver) {
  # use cols_only to skip the spurious extra anonymous columns due to trailing TAB
  cols <- readr::cols_only(
    UNIT_CODE = col_character(),
    FL        = col_integer(),
    FT        = col_double(),
    FD        = col_double(),
    DH        = col_double(),
    TX        = col_double(),
    TXH       = col_double(),
    TXV       = col_double(),
    TXS       = col_double(),
    N         = col_integer(),
    NCELL     = col_integer()
  )
  
  ff <- purrr::partial(read_traffic_complexity,
                       cols = cols,
                       upload_date = upd,
                       db_table = tbl,
                       bada_ver = bada,
                       sw_ver = ver)

  purrr::map_dfr(ifiles, .f = ff) %>% 
    readr::write_csv("traffic_complexity.csv", na = "")
}

generate_tc_upload(ifiles)
