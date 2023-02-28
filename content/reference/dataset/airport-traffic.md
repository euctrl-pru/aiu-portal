---
title: Airport Traffic Dataset
slug: airport-traffic
---

## Data description
The data provides the number of arrivals and departures from various data sources at the respective airports.

## Column naming and types

| Column name   | Data Source      | Label                           | Description                                         | Example    |
|---------------|------------------|---------------------------------|-----------------------------------------------------|------------|
| YEAR          | Network Manager  | YEAR                            | Reference year                                      | 2014       |
| MONTH_NUM     | Network Manager  | MONTH                           | Month (numeric)                                     | 1          |
| MONTH_MON     | Network Manager  | MONTH_MON                       | Month (3-letter code)                               | JAN        |
| FLT_DATE      | Network Manager  | DATE_FLT                        | Date of flight                                      | 01-Jan-2014|
| APT_ICAO      | Network Manager  | APT_ICAO                        | ICAO 4-letter airport designator                    | EDDM       |
| APT_NAME      | PRU              | APT_NAME                        | Airport name                                        | Munich     |
| STATE_NAME    | PRU              | STATE_NAME                      | Name of the country in which the airport is located | Germany    |
| FLT_DEP_1     | Network Manager  | Departures - (NM)               | Number of IFR departures                            | 278        |
| FLT_ARR_1     | Network Manager  | IFR arrivals - (NM)             | Number of IFR arrivals                              | 241        |
| FLT_TOT_1     | Network Manager  | IFR flights (arr + dep) - (NM)  | Number total IFR movements                          | 519        |
| FLT_DEP_IFR_2 | Airport Operator | IFR departures - (APT)          | Number of IFR departures                            | 278        |
| FLT_ARR_IFR_2 | Airport Operator | IFR arrivals - (APT)            | Number of IFR arrivals                              | 241        |
| FLT_TOT_IFR_2 | Airport Operator | IFR flights (arr + dep) - (APT) | Number total IFR movements                          | 519        |
