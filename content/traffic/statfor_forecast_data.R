library(tidyverse)
library(statfor)
library(tsibble)
library(lubridate)
library(readxl)

# Final Version:
# Obtain actual data and MTFs since 2014.

use_dwh_on_prisme_live()

############################################# Get the actual data from the latest MTF ####################################

##must contact STATFOR team when a new forecast is released to change the 'statfor_id'
statfor_id <- 3950
#might be able to find the id here: list_fc_set_table()

df <- unpack_fc_pts_to_dataset(find_fc_method_in_fc_set(statfor_id, method=218)) %>% 
  
  # Convert to tibble
  as_tibble() %>%
  
  # Apply format 
  apply_format(list(geo1 = .fid_tr_s, geo2 = .fid_tr_s,  geo3 = .fid_tz_s)) %>%
  
  # Add labels into the new variable.
  mutate(dep_tr_name = as.character(labelled::to_factor(geo1)),
         arr_tr_name = as.character(labelled::to_factor(geo2)),
         tz_name = as.character(labelled::to_factor(geo3))) %>%
  
  # Add DAIO labels.
  mutate(daio = case_when(
    sub1 == 1 ~ "I",
    sub1 == 2 ~ "TI",
    sub1 == 3 ~ "AD",
    sub1 == 4 ~ "TAD",
    sub1 == 5 ~ "O",
    sub1 == 6 ~ "TO",
    sub1 == 7 ~ "other",
    sub1 == 8 ~ "total_other",
    sub1 == 9 ~ "T"
  )) %>%
  
  # Add scenario labels.
  mutate(scenario = case_when(
    rank == 2 ~ "Base",
    rank == 3 ~ "High",
    rank == 4 ~ "Low")) %>%
  filter(sub1 %in% c(1, 2, 3, 4, 5, 6, 9)) %>%
  select(datetime, dep_tr_name, arr_tr_name, tz_name, daio, scenario, value)

# Create clean file group by year, tz, scenario and daio.
df_clean <- df %>%
  mutate(year = year(datetime)) %>%
  group_by(year, tz_name, scenario, daio) %>%
  summarise(flights = sum(value, na.rm = T))

# Create df with actual data up to last year:
#The first year for which we have High Low data/ Latest year with actuals
last_year <- min((df_clean %>% 
       filter(scenario=='High'))$year)
     
df_actual <- df_clean |> filter(year <= last_year 
                                & scenario == "Base") |> 
  ungroup()

df_forecast <- df_clean |> filter(year > last_year ) |> 
  ungroup()


# Bind Actual data and MTFs
df_final <- bind_rows(df_actual, df_forecast) %>%
  mutate(tz_name = ifelse(tz_name=="-9999","NM Area",tz_name)) %>%
  filter(!tz_name %in% c("-9996", "-9997", "#-9999", "396", "Algeria", "Belarus", 
                         "D Region", "G Region", "H Region", "K Region", "O Region", "R Region", 
                         "Greenland", "Faroe Islands", "Egypt", "Libya", "Sudan", 
                         "Kazakhstan", "Tajikistan", "Tunisia", "Turkmenistan", "Russian Federation",
                         "VWA Region", "SES-SJU", "#SES-RP3", "ESRA02", "EU27_2013", "#SES-RP2"))


# Preparing data for portal
df_final_all <- df_final %>%
  #renaming columns
  select(Rank =  scenario,
         TZ = tz_name,
         DAIO = daio,
         Yr = year,
         mvts = flights)


