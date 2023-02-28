#!/usr/bin/env Rscript

"Export en-route daily delay and traffic to yearly CSV files.

Usage: export_ert_dly [-h] [-t TYPE] WEF TIL

  -h --help             show this help text
  -t TYPE, --type=TYPE  the TYPE of entity; one of ansp, fir [default: ansp]

Arguments:
  WEF  date from when to export data, format YYYY-MM-DD
  TIL  date till when to export data, format YYYY-MM-DD (non-inclusive)
" -> doc

suppressWarnings(suppressMessages(library(docopt)))

# retrieve the command-line arguments
opts <- docopt(doc)

types <- c("ansp", "fir")

if (!(opts$type %in% types)) {
  cat("Error: incorrect TYPE, it must be one of", paste0(types, collapse = ", "), "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  type <- opts$type
}

suppressWarnings(suppressMessages(library(lubridate)))
suppressWarnings(suppressMessages(library(purrr)))
suppressWarnings(suppressMessages(library('ROracle')))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))

safe_ymd <- safely(ymd)
wef <- safe_ymd(opts$WEF, quiet = TRUE)
til <- safe_ymd(opts$TIL, quiet = TRUE)

if (is.null(wef$result) || is.null(til$result)) {
  cat("Error: invalid WEF and/or TIL, it must be in YYYY-MM-DD format", "\n")
  cat(doc, "\n")
  q(status = -1)
} else {
  wef <- format(wef$result, "%Y-%m-%d")
  til <- format(til$result, "%Y-%m-%d")
}

usr <- Sys.getenv("PRU_DEV_USR")
pwd <- Sys.getenv("PRU_DEV_PWD")
dbn <- Sys.getenv("PRU_DEV_DBNAME")

if (usr == "") {
  cat("Error: you should at least set your DB user via PRU_DEV_USR")
  q(status = -1)
}



# NOTE: to be set before you create your ROracle connection!
# See http://www.oralytics.com/2015/05/r-roracle-and-oracle-date-formats_27.html
tz <- "UDT"
Sys.setenv("TZ" = tz)
Sys.setenv("ORA_SDTZ" = "UTC")

drv <- dbDriver("Oracle")
con <- dbConnect(drv, usr, pwd, dbname='porape5')

sqlq_ansp <- "WITH data AS (
SELECT
  *
FROM
  PRUDEV.V_PRU_FAC_TDC_DD
WHERE 
  ENTRY_DATE >= TO_DATE(?WEF, 'YYYY-MM-DD') AND
  ENTRY_DATE < TO_DATE(?TIL, 'YYYY-MM-DD')
)

SELECT 
to_char(ENTRY_DATE,'YYYY') as YEAR,
EXTRACT (MONTH FROM ENTRY_DATE) MONTH_NUM, 
to_char(ENTRY_DATE,'MON') as MONTH_MON,
ENTRY_DATE as FLT_DATE, 
case unit_name
when 'EUROCONTROL' then 'EUROCONTROL Area (MS)'
when 'SES Performance Scheme SES-RP1 based on ANSP' then 'SES Area (RP1)' 
end ENTITY_NAME,   
'AREA (AUA)' as ENTITY_TYPE, 
TTF_FLT as FLT_ERT_1,
TDM_ERT as DLY_ERT_1,
TDM_ERT_A as DLY_ERT_A_1, 
TDM_ERT_C as DLY_ERT_C_1, 
TDM_ERT_D as DLY_ERT_D_1, 
TDM_ERT_E as DLY_ERT_E_1,
TDM_ERT_G as DLY_ERT_G_1, 
TDM_ERT_I as DLY_ERT_I_1, 
TDM_ERT_M as DLY_ERT_M_1, 
TDM_ERT_N as DLY_ERT_N_1, 
TDM_ERT_O as DLY_ERT_O_1,
TDM_ERT_P as DLY_ERT_P_1, 
TDM_ERT_R as DLY_ERT_R_1, 
TDM_ERT_S as DLY_ERT_S_1, 
TDM_ERT_T as DLY_ERT_T_1, 
TDM_ERT_V as DLY_ERT_V_1, 
TDM_ERT_W as DLY_ERT_W_1,
TDM_ERT_NA as DLY_ERT_NA_1,
TDF_ERT as FLT_ERT_1_DLY,
TDF_15_ERT as FLT_ERT_1_DLY_15
FROM data
where 
(UNIT_PRU_TYPE = 'ZONE' and unit_id in (58)) or 
(UNIT_PRU_TYPE = 'ZONE_ANSP' and unit_id in (55))

UNION ALL 

SELECT 
to_char(ENTRY_DATE,'YYYY') as YEAR,
EXTRACT (MONTH FROM ENTRY_DATE) MONTH_NUM, 
to_char(ENTRY_DATE,'MON') as MONTH_MON,
ENTRY_DATE as FLT_DATE, 
unit_name as ENTITY_NAME,   
'ANSP (AUA)' as ENTITY_TYPE, 
TTF_FLT as FLT_ERT_1,
TDM_ERT as DLY_ERT_1,
TDM_ERT_A as DLY_ERT_A_1, 
TDM_ERT_C as DLY_ERT_C_1, 
TDM_ERT_D as DLY_ERT_D_1, 
TDM_ERT_E as DLY_ERT_E_1,
TDM_ERT_G as DLY_ERT_G_1, 
TDM_ERT_I as DLY_ERT_I_1, 
TDM_ERT_M as DLY_ERT_M_1, 
TDM_ERT_N as DLY_ERT_N_1, 
TDM_ERT_O as DLY_ERT_O_1,
TDM_ERT_P as DLY_ERT_P_1, 
TDM_ERT_R as DLY_ERT_R_1, 
TDM_ERT_S as DLY_ERT_S_1, 
TDM_ERT_T as DLY_ERT_T_1, 
TDM_ERT_V as DLY_ERT_V_1, 
TDM_ERT_W as DLY_ERT_W_1,
TDM_ERT_NA as DLY_ERT_NA_1,
TDF_ERT as FLT_ERT_1_DLY,
TDF_15_ERT as FLT_ERT_1_DLY_15
FROM data
where 
UNIT_PRU_TYPE = 'ANSP' and 
unit_name NOT in ('NATS','NATS (Oceanic)','HungaroControl','Israel AA', 'ONDA', 'UkSATSE',
'Avinor (Continental)','Avinor (Oceanic)','NAV Portugal (Santa Maria)',
'UNKNOWN','MILITARY','AIRPORT','PIA','BHANSA', 'KFOR (HungaroControl)' )

order by 4,5
"


sqlq_fir <- "WITH DATA AS (
  SELECT 
    * 
  FROM
    PRUDEV.V_PRU_FAC_TDC_DD
  WHERE
    ENTRY_DATE >= TO_DATE(?WEF, 'YYYY-MM-DD') AND
    ENTRY_DATE < TO_DATE(?TIL, 'YYYY-MM-DD')
)

SELECT 
to_char(ENTRY_DATE,'YYYY') as YEAR,
EXTRACT (MONTH FROM ENTRY_DATE) MONTH_NUM,  
to_char(ENTRY_DATE,'MON') as MONTH_MON,
ENTRY_DATE as FLT_DATE, 
case unit_name
when 'SES Performance Scheme SES-RP2 based on FIR' then 'SES Area (RP2)' 
end ENTITY_NAME,   
'AREA (FIR)' as ENTITY_TYPE, 
TTF_FLT as FLT_ERT_1,
TDM_ERT as DLY_ERT_1,
TDM_ERT_A as DLY_ERT_A_1, 
TDM_ERT_C as DLY_ERT_C_1, 
TDM_ERT_D as DLY_ERT_D_1, 
TDM_ERT_E as DLY_ERT_E_1,
TDM_ERT_G as DLY_ERT_G_1, 
TDM_ERT_I as DLY_ERT_I_1, 
TDM_ERT_M as DLY_ERT_M_1, 
TDM_ERT_N as DLY_ERT_N_1, 
TDM_ERT_O as DLY_ERT_O_1,
TDM_ERT_P as DLY_ERT_P_1, 
TDM_ERT_R as DLY_ERT_R_1, 
TDM_ERT_S as DLY_ERT_S_1, 
TDM_ERT_T as DLY_ERT_T_1, 
TDM_ERT_V as DLY_ERT_V_1, 
TDM_ERT_W as DLY_ERT_W_1,
TDM_ERT_NA as DLY_ERT_NA_1,
TDF_ERT as FLT_ERT_1_DLY,
TDF_15_ERT as FLT_ERT_1_DLY_15
FROM data
where 
(UNIT_PRU_TYPE = 'ZONE_FIR' and unit_id in (56))
and ENTRY_DATE >= '1-JAN-2015' 

UNION ALL 

SELECT 
to_char(ENTRY_DATE,'YYYY') as YEAR,
EXTRACT (MONTH FROM ENTRY_DATE) MONTH_NUM, 
to_char(ENTRY_DATE,'MON') as MONTH_MON,
ENTRY_DATE as FLT_DATE, 
unit_name as ENTITY_NAME,   
'FAB (FIR)' as ENTITY_TYPE, 
TTF_FLT as FLT_ERT_1,
TDM_ERT as DLY_ERT_1,
TDM_ERT_A as DLY_ERT_A_1, 
TDM_ERT_C as DLY_ERT_C_1, 
TDM_ERT_D as DLY_ERT_D_1, 
TDM_ERT_E as DLY_ERT_E_1,
TDM_ERT_G as DLY_ERT_G_1, 
TDM_ERT_I as DLY_ERT_I_1, 
TDM_ERT_M as DLY_ERT_M_1, 
TDM_ERT_N as DLY_ERT_N_1, 
TDM_ERT_O as DLY_ERT_O_1,
TDM_ERT_P as DLY_ERT_P_1, 
TDM_ERT_R as DLY_ERT_R_1, 
TDM_ERT_S as DLY_ERT_S_1, 
TDM_ERT_T as DLY_ERT_T_1, 
TDM_ERT_V as DLY_ERT_V_1, 
TDM_ERT_W as DLY_ERT_W_1,
TDM_ERT_NA as DLY_ERT_NA_1,
TDF_ERT as FLT_ERT_1_DLY,
TDF_15_ERT as FLT_ERT_1_DLY_15
FROM data
where 
UNIT_PRU_TYPE = 'FAB_FIR' and 
unit_name NOT in ('BLUE MED FAB (+Albania)')
and ENTRY_DATE >= '1-JAN-2015' 

UNION ALL 

SELECT 
to_char(ENTRY_DATE,'YYYY') as YEAR,
EXTRACT (MONTH FROM ENTRY_DATE) MONTH_NUM, 
to_char(ENTRY_DATE,'MON') as MONTH_MON,
ENTRY_DATE as FLT_DATE, 
unit_name as ENTITY_NAME,   
'COUNTRY (FIR)' as ENTITY_TYPE, 
TTF_FLT as FLT_ERT_1,
TDM_ERT as DLY_ERT_1,
TDM_ERT_A as DLY_ERT_A_1, 
TDM_ERT_C as DLY_ERT_C_1, 
TDM_ERT_D as DLY_ERT_D_1, 
TDM_ERT_E as DLY_ERT_E_1,
TDM_ERT_G as DLY_ERT_G_1, 
TDM_ERT_I as DLY_ERT_I_1, 
TDM_ERT_M as DLY_ERT_M_1, 
TDM_ERT_N as DLY_ERT_N_1, 
TDM_ERT_O as DLY_ERT_O_1,
TDM_ERT_P as DLY_ERT_P_1, 
TDM_ERT_R as DLY_ERT_R_1, 
TDM_ERT_S as DLY_ERT_S_1, 
TDM_ERT_T as DLY_ERT_T_1, 
TDM_ERT_V as DLY_ERT_V_1, 
TDM_ERT_W as DLY_ERT_W_1,
TDM_ERT_NA as DLY_ERT_NA_1,
TDF_ERT as FLT_ERT_1_DLY,
TDF_15_ERT as FLT_ERT_1_DLY_15
FROM data  --PRUDEV.V_PRU_FAC_TDC_DD
where 
UNIT_PRU_TYPE = 'COUNTRY_FIR' and 
(unit_code  in (select country_icao_code from V_PRU_REL_COUNTRY_ZONE where zone_id = 58) or unit_code in ('EG_CT', 'EG_OC', 'LEGC', 'LP_CT', 'LP_OC'))
and unit_name not in ('Ukraine')
and ENTRY_DATE >= '01-JAN-2013'
order by 4,5
"

if (type == "ansp") {
  sqlq <- sqlq_ansp
} else if (type == "fir") {
  sqlq <- sqlq_fir
} else {
  cat("Error: invalida TYPE,", type)
  q(status = -1)
}

query <- sqlInterpolate(con, sqlq, WEF = wef, TIL = til)
flt <- dbSendQuery(con, query)
data <- fetch(flt, n = -1) 

dbDisconnect(con)
Sys.unsetenv("TZ")
Sys.unsetenv("ORA_SDTZ")

data <- data %>%
  as_tibble() %>%
  mutate(
    YEAR = as.integer(YEAR),
    MONTH_NUM = as.integer(MONTH_NUM),
    FLT_ERT_1 = as.integer(FLT_ERT_1),
    DLY_ERT_1 = as.integer(DLY_ERT_1),
    DLY_ERT_A_1 = as.integer(DLY_ERT_A_1),
    DLY_ERT_C_1 = as.integer(DLY_ERT_C_1),
    DLY_ERT_D_1 = as.integer(DLY_ERT_D_1),
    DLY_ERT_E_1 = as.integer(DLY_ERT_E_1),
    DLY_ERT_G_1 = as.integer(DLY_ERT_G_1),
    DLY_ERT_I_1 = as.integer(DLY_ERT_I_1),
    DLY_ERT_M_1 = as.integer(DLY_ERT_M_1),
    DLY_ERT_N_1 = as.integer(DLY_ERT_N_1),
    DLY_ERT_O_1 = as.integer(DLY_ERT_O_1),
    DLY_ERT_P_1 = as.integer(DLY_ERT_P_1),
    DLY_ERT_R_1 = as.integer(DLY_ERT_R_1),
    DLY_ERT_S_1 = as.integer(DLY_ERT_S_1),
    DLY_ERT_T_1 = as.integer(DLY_ERT_T_1),
    DLY_ERT_V_1 = as.integer(DLY_ERT_V_1),
    DLY_ERT_W_1 = as.integer(DLY_ERT_W_1),
    DLY_ERT_NA_1 = as.integer(DLY_ERT_NA_1)
  ) %>%
  arrange(FLT_DATE, ENTITY_NAME)



mySave <- function(df, ftype) {
  y <- unique(df$YEAR)
  write_csv(df,
            file = here::here("static", "download", "csv", str_c("ert_dly_", ftype, "_", y, ".csv.bz2")),
            na = "")
  df
}

# use purrr::partial to pass ftype
s <- partial(mySave, ftype = type)

# one file per YEAR
data %>% group_by(YEAR) %>% do(s(.))
