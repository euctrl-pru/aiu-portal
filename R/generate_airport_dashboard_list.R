library(dplyr)
library(stringr)


# apt <- tribble(
#   ~icao, ~country, ~ready,
#   "EDDF", "Germany", TRUE,
#   "EDDM", "Germany", FALSE,
#   "EGLL", "United Kingdom", TRUE,
#   "EIDW", "Ireland", TRUE
# )

apt <- readr::read_csv("data-config/airports-dashboard.csv") %>%
  rename(icao    = APT_ICAO,
         country = APT_COUNTRY,
         name    = APT_NAME,
         ready   = DASHBOARD)

summary_section <- function(apt_df) {
  country <- apt_df %>% 
    pull(country) %>% 
    unique() %>% 
    sort() 
  id <- country %>% tolower() %>% str_replace(" ", "-")
  
  str_glue(
  "* [{country}](#{id})",
  country = country,
  id = id) %>% 
  str_c(collapse = "\n")
}


airport_section <- function(df) {
  ent <- df %>%
    mutate(ggg = ifelse(df$ready,
                        "* [NAME (APT)](APT.html)",
                        "* NAME (APT) (not available)"),
           ggg = str_replace_all(ggg, "APT", .data$icao),
           ggg = str_replace_all(ggg, "NAME", .data$name)) %>%
    pull(ggg)
    str_c(ent, collapse = "\n")
}

all_section <- function(x, y) {
  cc <- str_c(str_glue("## {country}", country = y$country[[1]]))
  aa <- airport_section(x)
  str_c(cc, "\n\n", aa , collapse = "\n")
}


country_section <- function(apt_df) {
  apt_df %>%
    group_by(country) %>%
    arrange(name) %>%
    group_map(.f = all_section) %>% 
    unlist() %>% 
    str_c(collapse = "\n\n")
}

# from https://tomizonor.wordpress.com/2013/04/17/file-utf8-windows/
writeUTF8 <- function(x, file, bom = FALSE) {
  con <- file(file, "wb")
  if(bom) writeBin(BOM, con, endian="little")
  writeBin(charToRaw(x), con, endian="little")
  close(con)
}

pre <- summary_section(apt)
big <- country_section(apt)

template <- "---
title: Dashboard - Airport
layout: default
---

<div class='index-links'>

{summary}

</div>

{block}
"

str_glue(template, summary = pre, block = big) %>% 
  writeUTF8(file = "content/dashboard/stakeholder/airport/db/_index.md")
