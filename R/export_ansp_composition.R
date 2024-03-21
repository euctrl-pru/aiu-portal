#!/usr/bin/env Rscript

"Export to CSV the ANSP composition in terms of AUA's.

Two files are generated:
* the first in 'data-config' directory called 'ansp-composition.csv'.
  It containes all AUAs per ANSP
* the second in 'data' directory called 'date-ansp-composition.yml'.
  It contains the date the above data have been extracted

Usage: export_ansp_composition [-h] DATE

  -h --help             show this help text

Arguments:
  DATE  the date, in YYYY-MM-DD format, when the ANSP composition is extracted for.
" -> doc

suppressMessages(library(docopt))

# retrieve the command-line arguments
opts <- docopt(doc)

suppressMessages(library(lubridate))
suppressMessages(library(aiuportal))
suppressMessages(library(readr))
suppressMessages(library(here))

instant <- ymd(opts$DATE, quiet = TRUE)


if (is.na(instant)) {
  cat("Error: invalid DATE, it must be in YYYY-MM-DD format", "\n")
  q(status = -1)
}


export_ansp_composition(on = instant) |>
  write_csv(file = here::here("data-config", "ansp-composition.csv"), na = "")

cat("date:", instant, file = here::here("data", "date-ansp-composition.yml"))
