#!/usr/bin/env Rscript

"Export to CSV daily HFE kpi's.

Usage: export_hfe [-h] [-o DIR]

  -h --help             show this help text
  -o DIR                directory where to save the output [default: .]
" -> doc

suppressWarnings(suppressMessages(library(docopt)))
suppressWarnings(suppressMessages(library(aiuportal)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))

# retrieve the command-line arguments
opts <- docopt(doc)

out_dir <- opts$o

if (!fs::dir_exists(out_dir)) {
  cat("Error: non-existing DIR", "\n")
  cat(doc, "\n")
  q(status = -1)
}

out_dir <- fs::path_abs(out_dir)


export_horizontal_flight_efficiency(wef = "2024-01-01") |>
  group_by(YEAR) %>% 
  group_walk(~ write_csv(.x, 
                         paste0(out_dir, "/",
                                    stringr::str_c("hfe_", .y$YEAR, ".csv.bz2")),
                         na = ""),
             .keep = TRUE)
