# Financial data ----
library(tidyverse)
library(readxl)

# 1. Export `Qry_Factsheet_data` from ACE_YYYY_factsheet.mdb
#    (it is in G:\HQ\dgof-pru\Data\Application\Ace\ACE Factsheet\YYYY\Database)

# 2. read locally and pick what is needed
fac <- read_xlsx("Qry_Factsheet_data.xlsx") %>% 
  janitor::clean_names() %>%
  select(-sk_converter_id)

# 3. Export as CSV for the Observable map
fac %>%
  write_csv("factsheets.csv")


# URLs to PDF files ----
library(tidyverse)
library(fs)

dir_ls("static/library/ace/ansp-factsheets") %>% 
  as_tibble() %>% 
  rename(filename = value) %>% 
  mutate(
    name = str_remove(filename, "^.*/"),
    name = str_remove(name, "\\.pdf$"),
    filename = paste0("https://ansperformance.eu",
                      str_remove(filename, "^static"))
  ) %>% 
  write_csv("pdfs.csv")


# GeoJSON for ANSPs ----
library(sf)

library(pruatlas)
library(glue)
library(here)
library(smoothr)
library(tidyverse)

fl_u <- 300
fl_l <- 200

airac <- 490

# 1. run export_ace_ansp_geojson.R from pruatlas with the AIRAC you need

# 2. create the files for upper and lower airspace
ansps <- read_sf(here(glue("ansp-ace-{airac}.geojson"))) %>%
  janitor::clean_names() %>%
  rename(min_fl = min_flight_level, max_fl = max_flight_level)
  

# upper airspace
ansps_u <- ansps %>%
  dplyr::filter(.$min_fl <= fl_u & fl_u <= .$max_fl, str_detect(name, "Oceanic", negate = TRUE)) %>%
  dplyr::filter(code != "NAVEP_SM")


# fill the hole in Italy (due to some military airspace?)
enav_u <- ansps_u %>%
  filter(code == "ENAV") %>%
  smoothr::fill_holes(units::set_units(10000, km^2))

ansps_u <- ansps_u %>%
  filter(code != "ENAV") %>%
  bind_rows(enav_u)


# lower airspace
ansps_l <- ansps %>%
  dplyr::filter(.$min_fl <= fl_l & fl_l <= .$max_fl, str_detect(name, "Oceanic", negate = TRUE)) %>%
  dplyr::filter(code != "NAVEP_SM")

enav_l <- ansps_l %>%
  filter(code == "ENAV") %>%
  smoothr::fill_holes(units::set_units(10000, km^2))

ansps_l <- ansps_l %>%
  filter(code != "ENAV") %>%
  bind_rows(enav_l)


# 3. visual checks
plot_country_ansp("DFS", "DFS, Germany", fl = fl_u, ansps = ansps_u)
plot_country_ansp("MUAC", "MUAC, EUROCONTROL", fl = fl_u, ansps = ansps_u)
plot_country_ansp("ENAV", "ENAV, Italy", fl = fl_u, ansps = ansps_u)
plot_country_ansp("BHANSA", "BHANSA, xxx", fl = fl_u, ansps = ansps_u)

plot_country_ansp("LVNL", "LVNL, The Netherlands", fl = fl_l, ansps = ansps_l)
plot_country_ansp("BELGOCONTROL", "skeyes, Belgium", fl = fl_l, ansps = ansps_l)
plot_country_ansp("DFS", "DFS, Germany", fl = fl_l, ansps = ansps_l)
plot_country_ansp("ENAV", "ENAV, Italy", fl = fl_l, ansps = ansps_l)
plot_country_ansp("AENA", "ENAIRE, Spain", fl = fl_l, ansps = ansps_l)

plot_country_ansp("BHANSA", "BHANSA, Bosnia and Herzegovina", fl = fl_l, ansps = ansps_l)


# 4. export as GEOJSON
ansps_u %>%
  st_write(glue("ansp_upper_{airac}.geojson"))
ansps_l %>%
  st_write(glue("ansp_lower_{airac}.geojson"))

# 5. load the exported geojson files in mapshaper.org,
#    execute `mapshaper -clean` and export as
#      ansp_lower_AIRAC.json
#      ansp_lower_AIRAC.json
#    respectively

# 6. reload "mapshaper -clean"-ed files and visual check
ansps_l <- read_sf("C:/Users/spi/Downloads/ansp_lower_490.json")
country_ansp("DHMI", ansps = ansps_l, fl = fl_l)
plot_country_ansp("DHMI", "DHMI, Turkey", fl = fl_l, ansps = ansps_l)
