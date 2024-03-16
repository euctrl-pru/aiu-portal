---
title: Continuous climb and descent Dataset
slug: continuous-climb-descent
---

## Data description
This data provides the results of the analysis of vertical flight profiles
during climb and descent at airports.
The methodology is desto measure and observe vertical flight efficiency
without highlighting specific reasons for the observed behaviour.
More detailed case studies are needed to find out reasons for particular
observations.

## Methodology

The methodology being applied for the characterisation of CCO/CDO is described
in the relevant [methodology page][cdo_cco_meth].


## Column naming and types

#' * NBR_FLIGHTS_DESCENT: the number of arriving flights
#' * TOT_DIST_LEVEL_NM_DESCENT: total distance flown level during descent (nautical miles)
#' * TOT_DIST_LVL_NM_DESC_BLW_70: total distance flown level during descent below FL075 (nautical miles)
#' * TOT_TIME_LEVEL_SECONDS_DESCENT: total time flown level during descent (seconds)
#' * TOT_TIME_LEVEL_SEC_DESC_BLW_70: total time flown level during descent below FL075 (seconds)
#' * MEDIAN_CDO_ALT: median CDO altitude (feet)
#' * NBR_CDO_FLIGHTS: the number of flights that are considered CDO during the whole descent (and don't have any considered level flight)
#' * NBR_CDO_FLIGHTS_BELOW_7000: the number of flights that are considered CDO below FL075 (and don't have any considered level flight below FL075)
#' * TOT_DELTA_CO2_KG_DESCENT: total delta of CO2 (kg) resulting from the time flown level in descent
#' * TOT_DELTA_CO2_KG_DESC_BLW_70: total delta of CO2 (kg) resulting from the time flown level below FL075 in descent
#' * NBR_FLIGHTS_CLIMB: the number of departing flights
#' * TOT_DIST_LEVEL_NM_CLIMB: total distance flown level during climb (nautical miles)
#' * TOT_DIST_LVL_NM_CLIMB_BLW_100: total distance flown level during climb below FL105 (nautical miles)
#' * TOT_TIME_LEVEL_SECONDS_CLIMB: total time flown level during climb (seconds)
#' * TOT_TIME_LVL_SEC_CLIMB_BLW_100: total time flown level during climb below FL105 (seconds)
#' * MEDIAN_CCO_ALT: median CCO altitude (feet)
#' * NBR_CCO_FLIGHTS: the number of flights that are considered CCO during the whole climb (and don't have any considered level flight)
#' * NBR_CCO_FLIGHTS_BELOW_10000: the number of flights that are considered CCO below FL105 (and don't have any considered level flight below FL105)
#' * TOT_DELTA_CO2_KG_CLIMB: total delta of CO2 (kg) resulting from the time flown level in climb
#' * TOT_DELTA_CO2_KG_CLIMB_BLW_100: total delta of CO2 (kg) resulting from the time flown level below FL075 in climb
#' * AIRPORT_NAME: the airport name and ICAO code



| Column name |	Data source |	Label	| Column description | Example |
|-------------|-------------|-------|--------------------|---------|
| YEAR        | Network Manager | YEAR | Reference year	 | 2022    |
| MONTH_NUM	  | Network Manager	| MONTH	| Month (numeric) |	7      |
| MONTH_MON   | Network Manager	| MONTH_MON	| Month (3-letter code) | JUL |
| APT_ICAO    | Network Manager	| APT_ICAO  |	ICAO 4-letter airport designator | LSZH |
| APT_NAME	  | PRU	            | APT_NAME	| Airport name | Zurich |
| STATE_NAME  |	PRU	            | STATE_NAME | Name of the country in which the airport is located | Switzerland |
| NBR_FLIGHTS_DESCENT | PRU     |	NBR_FLIGHTS_DESCENT |	Number of arriving flights |	10432 |
| TOT_DIST_LEVEL_NM_DESCENT |	PRU |	TOT_DIST_LEVEL_NM_DESCENT |	Total distance flown level during descent in nautical miles	| 203802,4208 |
| TOT_DIST_LEVEL_NM_DESCENT_BELOW_7000 | PRU |	TOT_DIST_LEVEL_NM_DESCENT_BELOW_7000	| Total distance flown level during descent below FL075 in nautical miles |	14765,26111 |
| TOT_TIME_LEVEL_SECONDS_DESCENT | PRU | TOT_TIME_LEVEL_SECONDS_DESCENT | Total time flown level during descent in seconds | 2040956 |
| TOT_TIME_LEVEL_SECONDS_DESCENT_BELOW_7000 |	PRU	| TOT_TIME_LEVEL_SECONDS_DESCENT_BELOW_7000 | Total time flown level during descent below FL075 in seconds | 253536 |
| MEDIAN_CDO_ALT | PRU	        | MEDIAN_CDO_ALT  | Median CDO altitude in feet | 12971 |
| NBR_CDO_FLIGHTS	| PRU         |	NBR_CDO_FLIGHTS	| Number of flights that are considered CDO during the whole descent (and don't have any considered level flight) |	1566 |
| NBR_CDO_FLIGHTS_BELOW_7000 | PRU | NBR_CDO_FLIGHTS_BELOW_7000 |	Number of flights that are considered CDO below FL075 (and don't have any considered level flight below FL075) | 7025 |
| TOT_DELTA_CO2_KG_DESCENT | PRU | TOT_DELTA_CO2_KG_DESCENT | Total delta of CO2 (kg) resulting from the time flown level in descent | 1010038 |
| TOT_DELTA_CO2_KG_DESCENT_BELOW_7000 |	PRU | TOT_DELTA_CO2_KG_DESCENT_BELOW_7000 |	Total delta of CO2 (kg) resulting from the time flown level below FL075 in descent |	183396 |
| NBR_FLIGHTS_CLIMB | PRU      | NBR_FLIGHTS_CLIMB | Number of departing flights | 10435 |
| TOT_DIST_LEVEL_NM_CLIMB |	PRU | TOT_DIST_LEVEL_NM_CLIMB | Total distance flown level during climb in nautical miles | 86163,75887 |
| TOT_DIST_LEVEL_NM_CLIMB_BELOW_10000	| PRU	| TOT_DIST_LEVEL_NM_CLIMB_BELOW_10000	| Total distance flown level during climb below FL105 in nautical miles |	641,4472257 |
| TOT_TIME_LEVEL_SECONDS_CLIMB | PRU | TOT_TIME_LEVEL_SECONDS_CLIMB |	Total time flown level during climb in seconds | 709589 |
| TOT_TIME_LEVEL_SECONDS_CLIMB_BELOW_10000 | PRU | TOT_TIME_LEVEL_SECONDS_CLIMB_BELOW_10000 | Total time flown level during climb below FL105 in seconds | 9180 |
| MEDIAN_CCO_ALT | PRU | MEDIAN_CCO_ALT | Median CCO altitude in feet |	32006 |
| NBR_CCO_FLIGHTS | PRU	 | NBR_CCO_FLIGHTS | Number of flights that are considered CCO during the whole climb (and don't have any considered level flight) | 6028 |
| NBR_CCO_FLIGHTS_BELOW_10000 | PRU | NBR_CCO_FLIGHTS_BELOW_10000 | Number of flights that are considered CCO below FL105 (and don't have any considered level flight below FL105) | 10262 |
| TOT_DELTA_CO2_KG_CLIMB | PRU | TOT_DELTA_CO2_KG_CLIMB | Total delta of CO2 (kg) resulting from the time flown level in climb | 125346 |
| TOT_DELTA_CO2_KG_CLIMB_BELOW_10000 | PRU | TOT_DELTA_CO2_KG_CLIMB_BELOW_10000 | Total delta of CO2 (kg) resulting from the time flown level below FL075 in climb | 4601 |
| AIRPORT_NAME | PRU | AIRPORT_NAME | airport name and ICAO code | Frankfurt (EDDF) |



[cdo_cco_meth]: {{< relref "/methodology/cd-vertical-flight-efficiency-pi.html" >}} "Vertical flight efficiency during climb and descent methodology"
