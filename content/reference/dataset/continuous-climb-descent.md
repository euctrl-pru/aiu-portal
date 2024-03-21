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



| Column name/ Label |	Data source	   | Column description                                                   | Example |
|--------------------|-----------------|----------------------------------------------------------------------|---------|
| YEAR               | Network Manager | Reference year	                                                      | 2022    |
| MONTH_NUM	         | Network Manager | Month (numeric)                                                      |	7       |
| MONTH_MON          | Network Manager | Month (3-letter code)                                                | JUL     |
| APT_ICAO           | Network Manager | ICAO 4-letter airport designator                                     | LSZH    |
| APT_NAME	         | PRU	           | Airport name                                                         | Zurich  |
| STATE_NAME         | PRU	           | Name of the country in which the airport is located                  | Switzerland |
| NBR_FLIGHTS_DESCENT                  | PRU       |	Number of arriving flights                              |	10432   |
| TOT_DIST_LEVEL_NM_DESCENT            |	PRU           |	Total distance flown level during descent in nautical miles	 | 203802,4208 |
| TOT_DIST_LEVEL_NM_DESCENT_BELOW_7000 | PRU | Total distance flown level during descent below FL075 in nautical miles |	14765,26111 |
| TOT_TIME_LEVEL_SECONDS_DESCENT | PRU | Total time flown level during descent in seconds                     | 2040956 |
| TOT_TIME_LEVEL_SECONDS_DESCENT_BELOW_7000 |	PRU	|Total time flown level during descent below FL075 in seconds | 253536 |
| MEDIAN_CDO_ALT     | PRU	           | Median CDO altitude in feet                                          | 12971   |
| NBR_CDO_FLIGHTS	   | PRU             | Number of flights that are considered CDO during the whole descent (and don't have any considered level flight) |	1566 |
| NBR_CDO_FLIGHTS_BELOW_7000 | PRU     | Number of flights that are considered CDO below FL075 (and don't have any considered level flight below FL075) | 7025 |
| TOT_DELTA_CO2_KG_DESCENT | PRU       | Total delta of CO2 (kg) resulting from the time flown level in descent | 1010038 |
| TOT_DELTA_CO2_KG_DESCENT_BELOW_7000  |	PRU | Total delta of CO2 (kg) resulting from the time flown level below FL075 in descent |	183396 |
| NBR_FLIGHTS_CLIMB  | PRU             | Number of departing flights                                          | 10435   |
| TOT_DIST_LEVEL_NM_CLIMB |	PRU        | Total distance flown level during climb in nautical miles            | 86163,75887 |
| TOT_DIST_LEVEL_NM_CLIMB_BELOW_10000	| PRU	| Total distance flown level during climb below FL105 in nautical miles |	641,4472257 |
| TOT_TIME_LEVEL_SECONDS_CLIMB | PRU   | Total time flown level during climb in seconds                       | 709589  |
| TOT_TIME_LEVEL_SECONDS_CLIMB_BELOW_10000 | PRU | Total time flown level during climb below FL105 in seconds | 9180    |
| MEDIAN_CCO_ALT    | PRU              | Median CCO altitude in feet                                          | 32006   |
| NBR_CCO_FLIGHTS   | PRU	             |  Number of flights that are considered CCO during the whole climb (and don't have any considered level flight) | 6028 |
| NBR_CCO_FLIGHTS_BELOW_10000 | PRU    | Number of flights that are considered CCO below FL105 (and don't have any considered level flight below FL105) | 10262 |
| TOT_DELTA_CO2_KG_CLIMB | PRU         | Total delta of CO2 (kg) resulting from the time flown level in climb | 125346  |
| TOT_DELTA_CO2_KG_CLIMB_BELOW_10000 | PRU | Total delta of CO2 (kg) resulting from the time flown level below FL075 in climb | 4601 |
| AIRPORT_NAME      | PRU              | airport name and ICAO code                                           | Frankfurt (EDDF) |



[cdo_cco_meth]: {{< relref "/methodology/cd-vertical-flight-efficiency-pi.html" >}} "Vertical flight efficiency during climb and descent methodology"
