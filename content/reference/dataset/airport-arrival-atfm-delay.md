---
title: Airport Arrival ATFM Delay Dataset
slug: airport-arrival-atfm-delay
---

Please note that software release 20.0 of the Network Manager on 04 April 2016
introduced a change to improve the accuracy of the ATFM delay calculation for
operational purposes.
For more information on the change in methodology [click here][atfm_dly_rea].

[atfm_dly_rea]: {{< relref "/methodology/atfm-delay-calculation.md" >}} "ATFM Delay calculation changes due to REA"


## Data description

The *Airport Arrival ATFM Delay* provides an indication of
[ATFM delays]({{< relref "/definition/atfm-delay.html" >}})
on the ground due to constraints at airports.

In Europe, when traffic demand is anticipated to exceed the available capacity
in en route centres or at airports, Air Traffic Control
([ATC]({{< relref "/acronym/atc.md" >}})) units may request
the local Flow Management Position ([FMP]({{< relref "/acronym/fmp.md" >}})) to
instigate an Air Traffic Flow Management
([ATFM]({{< relref "/acronym/atfm.md" >}})) measure, or
[regulation]({{< relref "/definition/regulation.md" >}}).
Aircraft expected to arrive during a period of congestion are given ATFM delay
at their departure airport, under the authority of the
Network Manager, in order to regulate the flow of traffic into the constrained
downstream en route sector or airport, thus ensuring safety.

The resulting ATFM delays are calculated as the difference between the estimated
take-off time calculated from the filed flight plan including updates and the
calculated take-off time allocated by the central unit of ATFM.
The reason for the regulation is indicated by the responsible FMP.
The delay is attributed to the most constraining ATC unit.

The calculation of Airport arrival ATFM delay is based on a well established and
commonly accepted algorithm and has been in use as a commonly agreed proxy for
airport capacity shortfalls since 2009.

## Column naming and types

| Column name      | Data source     | Label                                | Reason Group         | Column description                                                                    | Example     |
|------------------|-----------------|--------------------------------------|----------------------|---------------------------------------------------------------------------------------|-------------|
| YEAR             | Network Manager | YEAR                                 |                      | Reference year                                                                        | 2015        |
| MONTH_NUM        | Network Manager | MONTH                                |                      | Month (numeric)                                                                       | 2           |
| MONTH_MON        | Network Manager | MONTH_MON                            |                      | Month (3-letter code)                                                                 | FEB         |
| FLT_DATE         | Network Manager | FLT_DATE                             |                      | Date of the flight                                                                    | 11/02/2015 (*) |
| APT_ICAO         | Network Manager | APT_ICAO                             |                      | ICAO 4-letter airport designator                                                      | LSGG        |
| APT_NAME         | PRU             | APT_NAME                             |                      | Airport name                                                                          | Geneva      |
| STATE_NAME       | PRU             | STATE_NAME                           |                      | Name of the country in which the airport is located                                   | Switzerland |
| FLT_ARR_1        | Network Manager | IFR Arrivals                         |                      | Number of arrivals (based on activated flight plans submitted to NM)                  | 221         |
| DLY_APT_ARR_1    | Network Manager | Airport ATFM arrival delay           |                      | Minutes of airport arrival ATFM delay                                                 | 1312        |
| DLY_APT_ARR_A_1  | Network Manager | A - Accident/Incident - AD           | AD Disruptions       | Minutes of airport arrival ATFM delay with delay code A - Accident/Incident           | 0           |
| DLY_APT_ARR_C_1  | Network Manager | C - ATC Capacity - AD                | AD Capacity (ATC)    | Minutes of airport arrival ATFM delay with delay code C - ATC Capacity                | 0           |
| DLY_APT_ARR_D_1  | Network Manager | D - De-icing - AD                    | AD Weather           | Minutes of airport arrival ATFM delay with delay code D - De-icing                    | 0           |
| DLY_APT_ARR_E_1  | Network Manager | E - Equipment (non-ATC) - AD         | AD Disruptions       | Minutes of airport arrival ATFM delay with delay code E - Equipment (non-ATC)         | 0           |
| DLY_APT_ARR_G_1  | Network Manager | G - Aerodrome Capacity - AD          | AD Capacity          | Minutes of airport arrival ATFM delay with delay code G - Aerodrome Capacity          | 0           |
| DLY_APT_ARR_I_1  | Network Manager | I - Industrial Action (ATC) - AD     | AD Disruptions (ATC) | Minutes of airport arrival ATFM delay with delay code I - Industrial Action (ATC)     | 0           |
| DLY_APT_ARR_M_1  | Network Manager | M - Airspace Management - AD         | AD Capacity          | Minutes of airport arrival ATFM delay with delay code M - Airspace Management         | 0           |
| DLY_APT_ARR_N_1  | Network Manager | N - Industrial Action (non-ATC) - AD | AD Disruptions       | Minutes of airport arrival ATFM delay with delay code N - Industrial Action (non-ATC) | 0           |
| DLY_APT_ARR_O_1  | Network Manager | O - Other - AD                       | AD Disruptions       | Minutes of airport arrival ATFM delay with delay code O - Other                       | 0           |
| DLY_APT_ARR_P_1  | Network Manager | P - Special Event - AD               | AD Events            | Minutes of airport arrival ATFM delay with delay code P - Special Event               | 0           |
| DLY_APT_ARR_R_1  | Network Manager | R - ATC Routeing - AD                | AD Capacity          | Minutes of airport arrival ATFM delay with delay code R - ATC Routeing                | 0           |
| DLY_APT_ARR_S_1  | Network Manager | S - ATC Staffing - AD                | AD Staffing (ATC)    | Minutes of airport arrival ATFM delay with delay code S - ATC Staffing                | 1312        |
| DLY_APT_ARR_T_1  | Network Manager | T - Equipment (ATC) - AD             | AD Disruptions (ATC) | Minutes of airport arrival ATFM delay with delay code T - Equipment (ATC)             | 0           |
| DLY_APT_ARR_V_1  | Network Manager | V - Environmental Issues - AD        | AD Capacity          | Minutes of airport arrival ATFM delay with delay code V - Environmental Issues        | 0           |
| DLY_APT_ARR_W_1  | Network Manager | W - Weather - AD                     | AD Weather           | Minutes of airport arrival ATFM delay with delay code W - Weather                     | 0           |
| DLY_APT_ARR_NA_1 | Network Manager | NA - Not specified - AD              | AD Disruptions       | Minutes of airport arrival ATFM delay with delay code NA - Not specified              | 0           |
| FLT_ARR_1_DLY    | Network Manager | FLT_ARR_1_DLY                        |                      | Number of airport ATFM arrival delayed arrivals                                       | 0           |
| FLT_ARR_1_DLY_15 | Network Manager | FLT_ARR_1_DLY_15                     |                      | Number of airport ATFM arrival delayed arrivals (>15 min.)                            | 0           |


(*) The [Airport Arrival ATFM Delay CSV files]({{< relref "/csv.md" >}})
use [ISO 8601][iso8601] date time format,
i.e. `2017-01-02T00:00:00Z`

[iso8601]: https://en.wikipedia.org/wiki/ISO_8601 "Wikipedia: ISO 8601"
