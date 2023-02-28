library(fs)
library(here)
library(magrittr)
library(dplyr)
library(purrr)
library(blogdown)

# this could fail if MS Windows keeps hold of some files!
# Then repeat it
dest <- here("content","dashboard","stakeholder", "airport","db")
src <- here("..","pru-airport-dashboard")

# delete everything which is not .Rmd
dir_ls(
  path = dest,
  glob = "*.Rmd",
  invert = TRUE,
  recurse = TRUE) %>%
  walk(.f = file_delete)
  

# copy files ...
dir_ls(
  path = here(src,"docs"),
  glob = "*.md",
  type = "file",
  invert = TRUE) %>%
  walk(.f = ~ file_copy(.x, dest))

# ... and the JS libs
dir_copy(path = here(src,"docs", "libs"),
         new_path = here(dest, "libs"),
         overwrite = TRUE)

file_copy(here(src, "data", "APT_DSHBD_AIRPORT.csv"),
          here("data-config"),
          overwrite = TRUE)

# regenerate _index.html
rmarkdown::render_site(here(dest, "_index.Rmd"),  encoding = 'UTF-8')
