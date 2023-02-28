#!/usr/bin/env Rscript

"Generate .bat script for calculation of Traffic Complexity.

Usage: make_tc_bat [-h] WEF TIL [-a APP] [-t TPFX] [-p OPFX] TRAFDIR BADAVER BADADIR ASDIR OUTDIR INI BAT

-h --help  show this help text
-a APP     the location of TC exe [default: C:/PruComplexity1.3/Application]
-t TPFX    the prefix for the traffic file [default: TRAFFIC]
-p OPFX    the prefix for the output file [default: complexity]

Arguments:
  WEF      date from, format YYYY-MM-DD
  TIL      date till, format YYYY-MM-DD (non-inclusive)
  TRAFDIR  dir of SO6 files (named like TRAFFIC_yyyymmdd.so6)
  BADAVER  version of BADA (and sub dir of BADADIR)
  BADADIR  dir of BADA files
  ASDIR    dir of Airspace files
  OUTDIR   dir of TC result CSV files
  INI      configuration file, .ini
  BAT      name of the .bat file
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

suppressMessages(library(stringr))
suppressMessages(library(tibble))
suppressMessages(library(trrrj))
suppressMessages(library(lubridate))
suppressMessages(library(dplyr))


# wef <- '2019-01-01'
# til <- '2019-03-01'
#
#
# app_dir <- "C:/PruComplexity1.3/Application"
# traffic_dir <- "G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Traffic"
#
# bada_ver <- "3_13"
# bada_base_dir <- "G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Bada"
# bada_dir <- str_glue("{dir}/{ver}", dir = bada_base_dir, ver = bada_ver)
#
# airspace_dir <- "G:/HQ/dgof-pru/Data/Application/Complexity_version_C/Data/Airspace"
# output_dir <- "C:/Users/spi/kaos/traffic_complexity_local/3.13"
#
# ini_file <- "C:/Users/spi/kaos/traffic_complexity_local/config_aua_spi.ini"


# app_dir <- opts$a
# bada_dir <- str_glue("{dir}/{ver}", dir = opts$BADADIR, ver = opts$BADAVER)
# df <- tibble::tibble(dd, airac)
#

# generate the sequence of dates and the relevant (CFMU) AIRAC numbers
dates <- seq(ymd(opts$WEF), ymd(opts$TIL) - 1, by = '1 day')
ndays <- length(dates)

strings <- tibble(
  date          = dates,
  airac_cfmu    = dates %>% cfmu_airac(),
  app_dir       = rep(opts$a,       ndays),
  airspace_dir  = rep(opts$ASDIR,   ndays),
  traffic_dir   = rep(opts$TRAFDIR, ndays),
  traffic_prfx  = rep(opts$t,       ndays),
  bada_base_dir = rep(opts$BADADIR, ndays),
  bada_ver      = rep(opts$BADAVER, ndays),
  output_dir    = rep(opts$OUTDIR,  ndays),
  output_prfx   = rep(opts$p,       ndays),
  ini_file      = rep(opts$INI,     ndays)
) %>%
  mutate(
    yymmdd   = format(date, "%y%m%d"),
    yyyymmdd = format(date, "%Y%m%d")
  )


if (fs::file_exists(opts$BAT)) {
  message(paste0(opts$BAT, " already exist, please choose another filename."))
  quit(status = -1)
}

f <- fs::file_create(opts$BAT)


# print("C:")
# print(str_glue('cd "{APPDIR}"', APPDIR = opts$a))

strings %>%
  str_glue_data('call {app_dir}/pruciMain.exe {yymmdd}  "{traffic_dir}/{traffic_prfx}_{yyyymmdd}.so6" "{airspace_dir}/airspace_prisme_{airac_cfmu}.prisme" "{bada_base_dir}/{bada_ver}/TB_OGIS_BADA_AIRCRAFT_PERF.txt" "{bada_base_dir}/{bada_ver}/TB_OGIS_BADA_AIRCRAFT_TYPE.txt"  "{output_dir}" "{ini_file}"  -o "{output_prfx}_{yyyymmdd}_bada_{bada_ver}.csv"\n ren pruci.log pruci-{yyyymmdd}.log') %>%
  writeLines(f)
cat("pause", file = f, append = TRUE)




