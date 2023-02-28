---
title: En-Route IFR Flights Dataset
slug: en-route-traffic
---

## Data description
The data provides the number of IFR flights within the respective airspace.

## Column naming and types

| Column name | Data source     | Label       | Column description                                             | Example    |
|-------------|-----------------|-------------|----------------------------------------------------------------|------------|
| YEAR        | Network Manager | YEAR        | Reference year                                                 | 2015       |
| MONTH_NUM   | Network Manager | MONTH       | Month (numeric)                                                | 3          |
| MONTH_MON   | Network Manager | MONTH_MON   | Month (3-letter code)                                          | MAR        |
| FLT_DATE    | Network Manager | FLT_DATE    | Date of flight                                                 | 17-Mar-2015|
| ENTITY_NAME | PRU             | ENTITY_NAME | Entity name                                                    | FAB CE     |
| ENTITY_TYPE | PRU             | ENTITY_TYPE | Type of the entity to which the data relates (ANSP, FAB, AREA) | FAB (AUA)  |
| FLT_ERT_1   | Network Manager | Flights     | Total number of flights within the respective airspace         | 3853       |
