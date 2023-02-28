---
title: ACE Monthly Operational Data Dataset
slug: ace-monthly-operational-data
---

## Data description

The ATM Cost-Effectiveness (ACE) operational data is published each month as complementary data for
the report which is published in May each year.

## ANSP

### Column naming and types

| Column name      | Data Source     | Label                           | Description                                                                    | Example  |
|------------------|-----------------|---------------------------------|--------------------------------------------------------------------------------|----------|
| YEAR             | Network Manager | YEAR                            | Reference year                                                                 | 2014     |
| MONTH_NUM        | Network Manager | MONTH                           | Month (numeric)                                                                | 1        |
| ANSP_NAME        | Network Manager | ANSP_NAME                       | Name of the Air Navigation Service Provider (ANSP)                             | DSNA     |
| FLT_1            | Network Manager | IFR flights                     | Number of IFR flights                                                          | 189824   |
| DIST_KM_1        | Network Manager |                                 | Distance in kilometer                                                          | 61       |
| DUR_MIN_1        | Network Manager |                                 | Duration in minutes                                                            | 8511400  |
| FLT_DLY_1        | Network Manager |                                 | IFR flights with ATFM delay                                                    | 4360     |
| FLT_DLY_15_1     | Network Manager |                                 | IFR flights with ATFM delay >15 min.                                           | 2565     |
| DLY_1            | Network Manager | ATFM delay                      | Minutes of ATFM delay                                                          | 105137   |
| DLY_15_1         | Network Manager | ATFM delay > 15 min             | Minutes of ATFM delay >15 minutes                                              | 89409    |
| FLT_DLY_APT_1    | Network Manager |                                 | IFR flights with airport ATFM delay                                            | 1014     |
| FLT_DLY_APT_15_1 | Network Manager |                                 | IFR flights with airport ATFM delay >15 min.                                   | 643      |
| DLY_APT_1        | Network Manager |                                 | Minutes of airport ATFM delay                                                  | 25611    |
| DLY_APT_15_1     | Network Manager |                                 | Minutes of airport ATFM delay >15 minutes                                      | 22362    |
| FLT_DLY_ERT_1    | Network Manager |                                 | IFR flights with en-route ATFM delay                                           | 3346     |
| FLT_DLY_ERT_15_1 | Network Manager |                                 | IFR flights with en-route ATFM delay >15 min.                                  | 1922     |
| DLY_ERT_1        | Network Manager | En-route ATFM delay             | Minutes of en-route ATFM delay                                                 | 79526    |
| DLY_ERT_15_1     | Network Manager | En-route ATFM delay > 15 min    | Minutes of en-route ATFM delay >15 minutes                                     | 67047    |
| DLY_ERT_A_1      | Network Manager | A - Accident/Incident           | Minutes of en-route ATFM delay with delay code A - Accident/Incident           | 0        |
| DLY_ERT_C_1      | Network Manager | C - ATC Capacity                | Minutes of en-route ATFM delay with delay code C - ATC Capacity                | 22081    |
| DLY_ERT_D_1      | Network Manager | D - De-icing                    | Minutes of en-route ATFM delay with delay code D - De-icing                    | 0        |
| DLY_ERT_E_1      | Network Manager | E - Equipment (non-ATC)         | Minutes of en-route ATFM delay with delay code E - Equipment (non-ATC)         | 0        |
| DLY_ERT_G_1      | Network Manager | G - Aerodrome Capacity          | Minutes of en-route ATFM delay with delay code G - Aerodrome Capacity          | 1065     |
| DLY_ERT_I_1      | Network Manager | I - Industrial Action (ATC)     | Minutes of en-route ATFM delay with delay code I - Industrial Action (ATC)     | 50843    |
| DLY_ERT_M_1      | Network Manager | M - Airspace Management         | Minutes of en-route ATFM delay with delay code M - Airspace Management         | 157      |
| DLY_ERT_N_1      | Network Manager | N - Industrial Action (non-ATC) | Minutes of en-route ATFM delay with delay code N - Industrial Action (non-ATC) | 0        |
| DLY_ERT_O_1      | Network Manager | O - Other                       | Minutes of en-route ATFM delay with delay code O - Other                       | 153      |
| DLY_ERT_P_1      | Network Manager | P - Special Event               | Minutes of en-route ATFM delay with delay code P - Special Event               | 0        |
| DLY_ERT_R_1      | Network Manager | R - ATC Routeing                | Minutes of en-route ATFM delay with delay code R - ATC Routeing                | 0        |
| DLY_ERT_S_1      | Network Manager | S - ATC Staffing                | Minutes of en-route ATFM delay with delay code S - ATC Staffing                | 2220     |
| DLY_ERT_T_1      | Network Manager | T - Equipment (ATC)             | Minutes of en-route ATFM delay with delay code T - Equipment (ATC)             | 2925     |
| DLY_ERT_V_1      | Network Manager | V - Environmental Issues        | Minutes of en-route ATFM delay with delay code V - Environmental Issues        | 0        |
| DLY_ERT_W_1      | Network Manager | W - Weather                     | Minutes of en-route ATFM delay with delay code W - Weather                     | 82       |
| DLY_ERT_NA_1     | Network Manager | NA - Not specified              | Minutes of en-route ATFM delay with delay code NA - Not specified              | 0        |



## Airport

### Column naming and types

| Column name     | Data Source     | Label                         | Description                                                      | Example            |
|-----------------|-----------------|-------------------------------|------------------------------------------------------------------|--------------------|
| YEAR            |                 | YEAR                          | Reference year                                                   | 2014               |
| MONTH_NUM       |                 | MONTH                         | Month (numeric)                                                  | 1                  |
| ANSP_NAME       |                 | ANSP_NAME                     | Name of the Air Navigation Service Provider (ANSP)               | PANSA              |
| APT_NAME        |                 | APT_NAME                      | Airport name                                                     | Leszno/Strzyzewice |
| APT_ICAO        |                 | APT_ICAO                      | ICAO 4-letter airport designator                                 | EPLS               |
| APT_ICAO_2ND    |                 | APT_ICAO_2ND                  | ICAO 4-letter airport designator (Airport Secondary ICAO Code)   | EPLS               |
| TYP_APT_SERVICE |                 | TYP_APT_SERVICE               | Type of service provided at the respective aerodrome (TWR, AFIS) | AFIS               |
| FLT_ARR_1       | Network Manager |                               | Number of IFR arrivals                                           | 2                  |
| FLT_DEP_1       | Network Manager |                               | Number of IFR departures                                         | 2                  |
| FLT_TOT_1       | Network Manager | Airport movements (arr + dep) | Number total IFR movements                                       | 4                  |


## ATC Unit

### Column naming and types

| Column name      | Data Source     | Label                           | Description                                                                    | Example        |
|------------------|-----------------|---------------------------------|--------------------------------------------------------------------------------|----------------|
| YEAR             | Network Manager | YEAR                            | Reference year                                                                 | 2014           |
| MONTH_NUM        | Network Manager | MONTH                           | Month (numeric)                                                                | 1              |
| ANSP_NAME        | Network Manager | ANSP_NAME                       | Name of the Air Navigation Service Provider (ANSP)                             | Austro Control |
| ENTITY_NAME      | Network Manager | ENTITY_NAME                     | ATC Unit Airspace (AUA) name                                                   | Wien           |
| ENTITY_TYPE      | Network Manager | ENTITY_TYPE                     | Type of entity for which the information is provided                           | ACC            |
| ENTITY_CODE      | Network Manager | ENTITY_CODE                     | Code of the entity for which the information is provided                       | LOVVACC        |
| FLT_1            | Network Manager | IFR flights                     | Number of IFR flights                                                          | 45612          |
| DIST_KM_1        | Network Manager |                                 | Distance in kilometer                                                          | 10012600,94    |
| DUR_MIN_1        | Network Manager |                                 | Duration in minutes                                                            | 772729         |
| FLT_DLY_1        | Network Manager |                                 | IFR flights with ATFM delay                                                    | 556            |
| FLT_DLY_15_1     | Network Manager |                                 | IFR flights with ATFM delay >15 min.                                           | 322            |
| DLY_1            | Network Manager | ATFM delay                      | Minutes of ATFM delay                                                          | 11262          |
| DLY_15_1         | Network Manager | ATFM delay > 15 min             | Minutes of ATFM delay >15 minutes                                              | 9209           |
| FLT_DLY_APT_1    | Network Manager |                                 | IFR flights with airport ATFM delay                                            | 501            |
| FLT_DLY_APT_15_1 | Network Manager |                                 | IFR flights with airport ATFM delay >15 min.                                   | 300            |
| DLY_APT_1        | Network Manager |                                 | Minutes of airport ATFM delay                                                  | 10481          |
| DLY_APT_15_1     | Network Manager |                                 | Minutes of airport ATFM delay >15 minutes                                      | 8716           |
| FLT_DLY_ERT_1    | Network Manager |                                 | IFR flights with en-route ATFM delay                                           | 55             |
| FLT_DLY_ERT_15_1 | Network Manager |                                 | IFR flights with en-route ATFM delay >15 min.                                  | 22             |
| DLY_ERT_1        | Network Manager | En-route ATFM delay             | Minutes of en-route ATFM delay                                                 | 781            |
| DLY_ERT_15_1     | Network Manager | En-route ATFM delay > 15 min    | Minutes of en-route ATFM delay >15 minutes                                     | 493            |
| DLY_ERT_A_1      | Network Manager | A - Accident/Incident           | Minutes of en-route ATFM delay with delay code A - Accident/Incident           | 0              |
| DLY_ERT_C_1      | Network Manager | C - ATC Capacity                | Minutes of en-route ATFM delay with delay code C - ATC Capacity                | 0              |
| DLY_ERT_D_1      | Network Manager | D - De-icing                    | Minutes of en-route ATFM delay with delay code D - De-icing                    | 0              |
| DLY_ERT_E_1      | Network Manager | E - Equipment (non-ATC)         | Minutes of en-route ATFM delay with delay code E - Equipment (non-ATC)         | 0              |
| DLY_ERT_G_1      | Network Manager | G - Aerodrome Capacity          | Minutes of en-route ATFM delay with delay code G - Aerodrome Capacity          | 0              |
| DLY_ERT_I_1      | Network Manager | I - Industrial Action (ATC)     | Minutes of en-route ATFM delay with delay code I - Industrial Action (ATC)     | 781            |
| DLY_ERT_M_1      | Network Manager | M - Airspace Management         | Minutes of en-route ATFM delay with delay code M - Airspace Management         | 0              |
| DLY_ERT_N_1      | Network Manager | N - Industrial Action (non-ATC) | Minutes of en-route ATFM delay with delay code N - Industrial Action (non-ATC) | 0              |
| DLY_ERT_O_1      | Network Manager | O - Other                       | Minutes of en-route ATFM delay with delay code O - Other                       | 0              |
| DLY_ERT_P_1      | Network Manager | P - Special Event               | Minutes of en-route ATFM delay with delay code P - Special Event               | 0              |
| DLY_ERT_R_1      | Network Manager | R - ATC Routeing                | Minutes of en-route ATFM delay with delay code R - ATC Routeing                | 0              |
| DLY_ERT_S_1      | Network Manager | S - ATC Staffing                | Minutes of en-route ATFM delay with delay code S - ATC Staffing                | 0              |
| DLY_ERT_T_1      | Network Manager | T - Equipment (ATC)             | Minutes of en-route ATFM delay with delay code T - Equipment (ATC)             | 0              |
| DLY_ERT_V_1      | Network Manager | V - Environmental Issues        | Minutes of en-route ATFM delay with delay code V - Environmental Issues        | 0              |
| DLY_ERT_W_1      | Network Manager | W - Weather                     | Minutes of en-route ATFM delay with delay code W - Weather                     | 0              |
| DLY_ERT_NA_1     | Network Manager | NA - Not specified              | Minutes of en-route ATFM delay with delay code NA - Not specified              | 0              |
