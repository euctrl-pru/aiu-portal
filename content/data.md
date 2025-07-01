---
title: "Data"
description: "Explore EUROCONTROL data on topics such as emissions, operations, traffic, economics and flight events."
aliases: ["/data/performancearea/"]
ndwk_i: <i class="fa pru fa-flask"></i>
fltr_i: <i class="fa pru fa-filter"></i>
attn_i: <i class="fa pru fa-exclamation-triangle"></i>
---

[icaoganp]: http://ansperformance.eu/references/acronym/ganp.html "ICAO GANP"

[ganp02]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=2 "GANP KPI 02"
[ganp03]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=3 "GANP KPI 03"
[ganp04]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=4 "GANP KPI 04"
[ganp05]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=5 "GANP KPI 05"

[ganp07]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=7 "GANP KPI 07"
[ganp08]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=8 "GANP KPI 08"

[ganp12]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=12 "GANP KPI 12"
[ganp13]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=13 "GANP KPI 13"

[ganp17]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=17 "GANP KPI 17"

[ganp19]: https://www4.icao.int/ganpportal/ASBU/KPI?IDs=19 "GANP KPI 19"

<br>

## <a href="https://flying-green.eurocontrol.int/#/" target="_blank"><img src="/images/eff/netzero.svg" width="60" height="60" alt="Gate-to-Gate Emissions"></a> Gate-to-Gate Emissions <small><small>– <a href="https://flying-green.eurocontrol.int/#/" target="_blank">Historical Flying Green NetZero Data</a></small></small>

| Data description                                                                                                  | Period                                                                       | {{< excel_i >}}            | {{< csv_i >}}              | {{< parquet_i >}}                     | Info                    |                                    |
|-------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|----------------------------|----------------------------|----------------------------------------|--------------------------|------------------------------------|
| Monthly Gate-to-Gate emissions by Network (Area focus)<br><small>Historical emissions (CO<sub>2</sub>/NO<sub>X</sub>/SO<sub>X</sub>) as per the [gate-to-gate emissions methodology][PRU_G2G]</small>  | {{< getdata "dwnld" "g2g_co_opt_beg" >}} - {{< getdata "dwnld" "g2g_co_opt_end" >}}  | [{{< dwnld_i >}}][g2gCOxlsx]  | [{{< dwnld_i >}}][g2gCOcsv]  | [{{< dwnld_i >}}][g2gCOparquet]         | [{{< info_i >}}][g2gCOmeta] |                                    |
| Monthly Gate-to-Gate emissions by State (Area focus)<br><small>Historical emissions (CO<sub>2</sub>/NO<sub>X</sub>/SO<sub>X</sub>) as per the [gate-to-gate emissions methodology][PRU_G2G]</small>   | {{< getdata "dwnld" "g2g_co_opt_beg" >}} - {{< getdata "dwnld" "g2g_co_opt_end" >}}  | [{{< dwnld_i >}}][g2gCOxlsx]  | [{{< dwnld_i >}}][g2gCOcsv]  | [{{< dwnld_i >}}][g2gCOparquet]         | [{{< info_i >}}][g2gCOmeta] |                                    |
<small><small> Developed in close collaboration with the [EUROCONTROL Aviation Sustainability Unit (ASU)][ENV] and the [EUROCONTROL Flying Green Initiative][FG]. These data sets contain the historical emissions as displayed in the [Flying Green NetZero][FG_NZ] dashboard.</small></small>

[g2gCOxlsx]: https://www.eurocontrol.int/performance/data/download/xls/CO2_emissions_by_state.xlsx "Gate-to-gate emissions (Excel)"
[g2gCOcsv]:  /csv/#co2-csv "Gate-to-gate emissions (CSV)"
[g2gCOparquet]:  /csv/#co2-parquet "Gate-to-gate emissions (Parquet)"
[g2gCOmeta]: /reference/dataset/g2g-emissions/ "Gate-to-gate emissions (Meta)"
[ENV]: https://www.eurocontrol.int/aviation-sustainability "EUROCONTROL Aviation Sustainability Unit (ASU)"
[FG]: https://flying-green.eurocontrol.int/#/ "EUROCONTROL Flying Green Initiative"
[FG_NZ]: https://flying-green.eurocontrol.int/#/net-zero "Flying Green NetZero"
[PRU_G2G]: /reference/dataset/g2g-emissions/ "PRU gate-to-gate emissions methodology"

## <a href="https://www.eurocontrol.int/tool/small-emitters-tool" target="_blank"><img src="/images/eff/ectl_env2.jpg" width="60" height="60" alt="CO<sub>2</sub> Emissions - SET"></a> CO<sub>2</sub> Emissions <small><small>- <a href="https://www.eurocontrol.int/tool/small-emitters-tool" target="_blank">Small Emitters Tool</a></small></small>

| Data description                                                                                                  | Period                                                                       | {{< excel_i >}}            | {{< csv_i >}}              |  Info                    |                                    |
|-------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|----------------------------|----------------------------|--------------------------|------------------------------------|
| Monthly CO<sub>2</sub> emissions by State (Departing trajectory focus) <br><small>Historical CO<sub>2</sub> emissions as calculated by the [ASU methodology using the Small Emitters Tool (SET)][COmeta]</small>  | {{< getdata "dwnld" "co_opt_beg" >}} - {{< getdata "dwnld" "co_opt_end" >}}  | [{{< dwnld_i >}}][COxlsx]  |  [{{< dwnld_i >}}][COcsv]  | [{{< info_i >}}][COmeta] |                                    |
<small><small> Supplied by the [EUROCONTROL Aviation Sustainability Unit (ASU)][ENV]. </small></small>

[COxlsx]: https://www.eurocontrol.int/performance/data/download/xls/CO2_emissions_by_state.xlsx "CO<sub>2</sub> (Excel)"
[COcsv]:  /csv/#co2-csv "CO<sub>2</sub> (CSV)"
[COmeta]: /reference/dataset/emissions/ "CO<sub>2</sub> (Meta)"
[ENV]: https://www.eurocontrol.int/aviation-sustainability "EUROCONTROL Aviation Sustainability Unit"

## <img src="/images/prcq-operations-enroute.png" width="50" height="50" alt="Operations En-route"> Operations En-route

| Data description                                                                                                                                                                                                        | Period                                                                                           | {{< excel_i >}}                         | {{< csv_i >}}                 | Info                               | [ICAO GANP][icaoganp]              |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|-----------------------------------------|-------------------------------|------------------------------------|------------------------------------|
| En-route IFR flights and ATFM delays ([AUA][DefAUA])<br><em>no post ops adjustments</em><br><small> Daily IFR traffic and en-route [ATFM delay][ATFMdelay] by entity and delay cause (AUA based)</small>                | {{< getdata "dwnld" "ert_dly_aua_beg" >}} - {{< getdata "dwnld" "ert_dly_aua_end" >}}            | [{{< dwnld_i >}}][ERT-DLY-AUAxlsx]      | [{{< dwnld_i >}}][ERT-DLYcsv] | [{{< info_i >}}][ERT-DLY-AUA-meta] | [KPI 07][ganp07]                   |
| En-route IFR flights and ATFM delays ([AUA][DefAUA])<br><em>[with post ops adjustments][PostOps]</em><br><small> Monthly IFR traffic and en-route [ATFM delay][ATFMdelay] by entity and delay cause (AUA based)</small> | {{< getdata "dwnld" "ert_dly_aua_post_beg" >}} - {{< getdata "dwnld" "ert_dly_aua_post_end" >}}  | [{{< dwnld_i >}}][ERT-DLY-AUA-postxlsx] |                               | [{{< info_i >}}][ERT-DLY-AUA-meta] | [KPI 07][ganp07]                   |
| En-route IFR flights and ATFM delays ([FIR][DefFIR])<br><em>no post ops adjustments</em><br><small> Daily IFR traffic and en-route [ATFM delay][ATFMdelay] by entity and delay cause (FIR based)</small>                | {{< getdata "dwnld" "ert_dly_fir_beg" >}} - {{< getdata "dwnld" "ert_dly_fir_end" >}}            | [{{< dwnld_i >}}][ERT-DLY-FIRxlsx]      | [{{< dwnld_i >}}][ERT-DLYcsv] | [{{< info_i >}}][ERT-DLY-FIR-meta] | [KPI 07][ganp07]                   |
| En-route IFR flights and ATFM delays ([FIR][DefFIR])<br><em>[with post ops adjustments][PostOps]</em><br><small> Monthly IFR traffic and en-route [ATFM delay][ATFMdelay] by entity and delay cause (FIR based)</small> | {{< getdata "dwnld" "ert_dly_fir_post_beg" >}} - {{< getdata "dwnld" "ert_dly_fir_post_end" >}}  | [{{< dwnld_i >}}][ERT-DLY-FIR-postxlsx] |                               | [{{< info_i >}}][ERT-DLY-FIR-meta] | [KPI 07][ganp07]                   |
| Horizontal en-route flight efficiency <br><small>Daily [en-route flight efficiency][DefFE] data by entity ([KEP][DefKEP] and [KEA][DefKEA])</small>                                                                     | {{< getdata "dwnld" "hfe_beg" >}} - {{< getdata "dwnld" "hfe_end" >}}                            | [{{< dwnld_i >}}][HFExlsx]              | [{{< dwnld_i >}}][HFEcsv] | [{{< info_i >}}][HFEmeta]          | [KPI 04][ganp04], [KPI 05][ganp05] |

[ATFMdelay]: /definition/atfm-delay/ "ATFM Delay definition"

[ERT-DLY-AUAxlsx]: https://www.eurocontrol.int/performance/data/download/xls/En-Route_ATFM_Delay_AUA.xlsx "ERT-DLY (Excel)"
[ERT-DLY-AUA-postxlsx]: https://www.eurocontrol.int/performance/data/download/xls/En-Route_ATFM_Delay_AUA_post_ops.xlsx "ERT-DLY-PO (Excel)"

[ERT-DLY-FIRxlsx]: https://www.eurocontrol.int/performance/data/download/xls/En-Route_ATFM_Delay_FIR.xlsx "ERT-DLY (Excel)"
[ERT-DLY-FIR-postxlsx]: https://www.eurocontrol.int/performance/data/download/xls/En-Route_ATFM_Delay_FIR_post_ops.xlsx "ERT-DLY-PO (Excel)"

[ERT-DLYcsv]: /csv/#ertdly-csv "ERT-DLY (CSV)"
[ERT-DLY-AUA-meta]: /reference/dataset/en-route-atfm-delay-aua/ "ERT-DLY (Meta)"
[ERT-DLY-FIR-meta]: /reference/dataset/en-route-atfm-delay-fir/ "ERT-DLY (Meta)"

[HFExlsx]: https://www.eurocontrol.int/performance/data/download/xls/Horizontal_Flight_Efficiency.xlsx "HFE (Excel)"
[HFEcsv]: /csv/#hfe-csv "HFE (CSV)"
[HFEmeta]: /reference/dataset/horizontal-flight-efficiency/ "HFE (Meta)"

[DefAUA]: /acronym/aua/ "AUA definition"
[DefFIR]: /acronym/fir/ "FIR definition"
[DefFE]:  /methodology/horizontal-flight-efficiency-pi/ "Flight Efficiency performance indicator"
[DefKEP]: /acronym/kep/ "Key performance Environment indicator based on last filed flight Plan"
[DefKEA]: /acronym/kea/ "Key performance Environment indicator based on Actual trajectory"

[PostOps]: https://www.eurocontrol.int/service/post-operations-performance-adjustment "Post ops adjustment process"


## <img src="/images/prcq-operations-airport.png" width="50" height="50" alt="Operations at Airports"> Operations at Airports


| Data description                                                                                                                                                                                 | Period                                                                                  | {{< excel_i >}}                     | {{< csv_i >}}                  |  Info                           | [ICAO GANP][icaoganp]              |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-------------------------------------|--------------------------------|---------------------------------|------------------------------------|
| Airport traffic<br><small> Daily IFR arrivals and departures by airport</small>                                                                                                                  | {{< getdata "dwnld" "apt_flt_beg" >}} - {{< getdata "dwnld" "apt_flt_end" >}}           | [{{< dwnld_i >}}][APT-FLTxlsx]      | [{{< dwnld_i >}}][APT-FLTcsv]  | [{{< info_i >}}][APT-FLTmeta]   |                                    |
| Airport arrival ATFM delays - <em> (no post ops adjustments)</em><br><small> Daily IFR arrivals and airport arrival [ATFM delay][ATFMdelay] by airport and delay category</small>                | {{< getdata "dwnld" "apt_dly_beg" >}} - {{< getdata "dwnld" "apt_dly_end" >}}           | [{{< dwnld_i >}}][APT-DLYxlsx]      | [{{< dwnld_i >}}][APT-DLYcsv]  | [{{< info_i >}}][APT-DLYmeta]   | [KPI 12][ganp12]                   |
| Airport arrival ATFM delays - <em> [(with post ops adjustments)][PostOps]</em><br><small> Monthly IFR arrivals and airport arrival [ATFM delay][ATFMdelay] by airport and delay category</small> | {{< getdata "dwnld" "apt_dly_post_beg" >}} - {{< getdata "dwnld" "apt_dly_post_end" >}} | [{{< dwnld_i >}}][APT-DLY-postxlsx] |                                | [{{< info_i >}}][APT-DLYmeta]   | [KPI 12][ganp12]                   |                               |
| Arrival Sequencing and Metering (ASMA) additional time<br><small> Monthly [ASMA additional][ASMAadditional] time</small>                     | {{< getdata "dwnld" "asma_beg" >}} - {{< getdata "dwnld" "asma_end" >}}                 | [{{< dwnld_i >}}][ASMAxlsx]         | [{{< dwnld_i >}}][ASMAcsv]     | [{{< info_i >}}][ASMAmeta]      | [KPI 08][ganp08]                   |
| Vertical flight efficiency - Continuous climb and descent operations<br><small> Monthly continuous climb and descent data including CO<sub>2</sub> emissions</small>                             | {{< getdata "dwnld" "cdo_beg" >}} - {{< getdata "dwnld" "cdo_end" >}}                   | [{{< dwnld_i >}}][CDOxlsx]          | [{{< dwnld_i >}}][CDOcsv]      | [{{< info_i >}}][CDOmeta]       | [KPI 17][ganp17], [KPI 19][ganp19] |
| Taxi-out additional time<br><small> Monthly [taxi out additional][TX-OUTadditional] time</small>                                             | {{< getdata "dwnld" "tx_out_beg" >}} - {{< getdata "dwnld" "tx_out_end" >}}             | [{{< dwnld_i >}}][TX-OUTxlsx]       | [{{< dwnld_i >}}][TX-OUTcsv]   | [{{< info_i >}}][TX-OUTmeta]    | [KPI 02][ganp02]                   |
| Taxi-in additional time<br><small> Monthly [taxi in additional][TX-INadditional] time</small>                                                | {{< getdata "dwnld" "tx_in_beg" >}} - {{< getdata "dwnld" "tx_in_end" >}}               | [{{< dwnld_i >}}][TX-INxlsx]        | [{{< dwnld_i >}}][TX-INcsv]    | [{{< info_i >}}][TX-INmeta]     | [KPI 13][ganp13]                   |
| Taxi-time planning values<br><small> Taxi time planning values, by IATA season for airline schedulers supplied by [CODA][coda]</small>                                                           | {{< getdata "dwnld" "tx_std_beg" >}} - {{< getdata "dwnld" "tx_std_end" >}}             | [{{< dwnld_i >}}][TX-Stdxlsx]       |                                | [{{< info_i >}}][TX-Stdmeta]    |                                    |
| ATC pre-departure delays<br><small> Daily [ATC pre-departure delay][ATCpredepdelay] by airport</small>                                                                                           | {{< getdata "dwnld" "atc_pre_beg" >}} - {{< getdata "dwnld" "atc_pre_end" >}}           | [{{< dwnld_i >}}][ATC-PRExlsx]      | [{{< dwnld_i >}}][ATC-PREcsv]  | [{{< info_i >}}][ATC-PREmeta]   |                                    |
| Total pre-departure delays<br><small> Daily total pre-departure delay by airport (all causes)</small>                                                                                            | {{< getdata "dwnld" "all_pre_beg" >}} - {{< getdata "dwnld" "all_pre_end" >}}           | [{{< dwnld_i >}}][ALL-PRExlsx]      | [{{< dwnld_i >}}][ALL-PREcsv]  | [{{< info_i >}}][ALL-PREmeta]   |                                    |
| ATFM slot adherence<br><small> Daily ATFM slot adherence by airport</small>                                                                                                                      | {{< getdata "dwnld" "slt_adh_beg" >}} - {{< getdata "dwnld" "slt_adh_end" >}}           | [{{< dwnld_i >}}][SLT-ADHxlsx]      | [{{< dwnld_i >}}][SLT-ADHcsv]  | [{{< info_i >}}][SLT-ADHmeta]   | [KPI 03][ganp03]                   |
| Arrival Sequencing and Metering (ASMA) additional time (old methodology)<br><small> Monthly [ASMA additional][ASMAadditional] time</small>                                                       | {{< getdata "dwnld" "asma_o_beg" >}} - {{< getdata "dwnld" "asma_o_end" >}}             | [{{< dwnld_i >}}][ASMA_o_xlsx]      |                                | [{{< info_i >}}][ASMA_o_meta]   |                                    |
| Taxi-out additional time (old methodology)<br><small> Monthly [taxi out additional][TX-OUTadditional] time</small>                                                                               | {{< getdata "dwnld" "tx_out_o_beg" >}} - {{< getdata "dwnld" "tx_out_o_end" >}}         | [{{< dwnld_i >}}][TX-OUT_o_xlsx]    |                                | [{{< info_i >}}][TX-OUT_o_meta] |                                    |

[ASMAadditional]:   /definition/additional-asma-time/ "ASMA Additional Time definition"
[TX-OUTadditional]: /definition/additional-taxi-out-time/ "Taxi-out Additional Time definition"
[TX-INadditional]: /definition/additional-taxi-in-time/ "Taxi-in Additional Time definition"
[ATCpredepdelay]:   /definition/atc-pre-departure-delay/ "ATC Pre-departure Delay definition"
[ALLpredepdelay]:   /definition/all-pre-departure-delay/ "All Pre-departure Delay definition"

[APT-FLTxlsx]:      https://www.eurocontrol.int/performance/data/download/xls/Airport_Traffic.xlsx "APT-FLT (Excel)"
[APT-DLY-postxlsx]: https://www.eurocontrol.int/performance/data/download/xls/Airport_Arrival_ATFM_Delay_post_ops.xlsx "APT-DLY-PO (Excel)"
[APT-FLTcsv]:       /csv/#aptflt-csv "APT-FLT (CSV)"
[APT-FLTmeta]:      /reference/dataset/airport-traffic/  "APT-FLT (Meta)"

[APT-DLYxlsx]: https://www.eurocontrol.int/performance/data/download/xls/Airport_Arrival_ATFM_Delay.xlsx "APT-DLY (Excel)"
[APT-DLYcsv]:  /csv/#aptdly-csv "APT-DLY (CSV)"
[APT-DLYmeta]: /reference/dataset/airport-arrival-atfm-delay/ "APT-DLY (Meta)"

[ASMAxlsx]: https://www.eurocontrol.int/performance/data/download/xls/ASMA_Additional_Time.xlsx "ASMA (Excel)"
[ASMA_o_xlsx]: https://www.eurocontrol.int/performance/data/download/xls/ASMA_Additional_Time_old.xlsx "ASMA (Excel)"
[ASMAcsv]: /csv/#asma-csv "ASMA (CSV)"
[ASMAmeta]: /reference/dataset/asma-additional-time/ "ASMA (Meta)"
[ASMA_o_meta]: /reference/dataset/asma-additional-time-old/ "ASMA (Meta)"

[TX-OUTxlsx]: https://www.eurocontrol.int/performance/data/download/xls/Taxi-Out_Additional_Time.xlsx "TX-OUT (Excel)"
[TX-OUT_o_xlsx]: https://www.eurocontrol.int/performance/data/download/xls/Taxi-Out_Additional_Time_old.xlsx "TX-OUT (Excel)"
[TX-OUTcsv]:  /csv/txout-csv "TX-OUT (CSV)"
[TX-OUTmeta]: /reference/dataset/taxi-out-additional-time/ "TX-OUT (Meta)"
[TX-OUT_o_meta]: /reference/dataset/taxi-out-additional-time-old/ "TX-OUT (Meta)"

[TX-INxlsx]: https://www.eurocontrol.int/performance/data/download/xls/Taxi-In_Additional_Time.xlsx "TX-IN (Excel)"
[TX-INcsv]:  /csv/#txin-csv "TX-IN (CSV)"
[TX-INmeta]: /reference/dataset/taxi-in-additional-time/ "TX-IN (Meta)"

[CDOxlsx]: https://www.eurocontrol.int/performance/data/download/xls/Vertical_Flight_Efficiency_cdo_cco.xlsx "CDO/CCO (Excel)"
[CDOcsv]:  /csv/#vfe-csv "CDO/CCO (CSV)"
[CDOmeta]: /reference/dataset/continuous-climb-descent/ "CDO/CCO (Meta)"

[TX-Stdxlsx]: https://www.eurocontrol.int/performance/data/download/xls/Taxi_times_Planning_Data_S14_S22.xlsx "TX-Std (Excel)"
[TX-Stdcsv]:  /404/ "TX-Std (CSV)"
[TX-Stdmeta]: /reference/dataset/planning-taxi-times/ "TX-Std (Meta)"
[coda]: /capacity/tot_dly/ "Coda"

[ATC-PRExlsx]: https://www.eurocontrol.int/performance/data/download/xls/ATC_Pre-Departure_Delay.xlsx "ATC-PRE (Excel)"
[ATC-PREcsv]:  /csv/#atcpre-csv "ATC-PRE (CSV)"
[ATC-PREmeta]: /reference/dataset/atc-pre-departure-delay/  "ATC-PRE (Meta)"

[ALL-PRExlsx]: https://www.eurocontrol.int/performance/data/download/xls/All_Pre-Departure_Delay.xlsx "All-PRE (Excel)"
[ALL-PREcsv]:  /csv/#allpre-csv "ALL-PRE (CSV)"
[ALL-PREmeta]: /reference/dataset/all-pre-departure-delay/  "All-PRE (Meta)"

[SLT-ADHxlsx]: https://www.eurocontrol.int/performance/data/download/xls/ATFM_Slot_Adherence.xlsx "SLT-ADH (Excel)"
[SLT-ADHcsv]:  /csv/#sltadh-csv "SLT-ADH (CSV)"
[SLT-ADHmeta]: /reference/dataset/atfm-slot-adherence/ "SLT-ADH (Meta)"



## <img src="/images/prcq-traffic.png" width="50" height="50" alt="Traffic"> Traffic

**NOTE**: the two Traffic Complexity time series, 2014 - 2016 and 2017 - 2019, **cannot** be used joinly to study the full time span 2014 - 2019.<br>
In fact they use different BADA versions and hence different aircraft characteristics for the same aircraft type; this impacts the value of the
*Speed Different Interacting Flows* and ultimately the *Traffic Complexity Score*.

| Data description                                                                             | Period                                                                                          | {{< excel_i >}}              | {{< csv_i >}} | Info                       |    |
|----------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|------------------------------|---------------|----------------------------|----|
| Complexity (based on [BADA][CPLXbada] version 3.6) <br><small> Complexity by ANSP</small>    | {{< getdata "dwnld" "cplx_beg_bada_3_6" >}} -  {{< getdata "dwnld" "cplx_end_bada_3_6" >}}      | [{{< dwnld_i >}}][CPLXxlsx]  |               | [{{< info_i >}}][CPLXmeta] |    |
| Complexity (based on [BADA][CPLXbada] version 3.13.1) <br><small> Complexity by ANSP</small> | {{< getdata "dwnld" "cplx_beg_bada_3_13_1" >}} - {{< getdata "dwnld" "cplx_end_bada_3_13_1" >}} | [{{< dwnld_i >}}][CPLX1xlsx] |               | [{{< info_i >}}][CPLXmeta] |    |

[CPLXxlsx]:  https://www.eurocontrol.int/performance/data/download/xls/Traffic_Complexity_Scores_1.xlsm "CPLX (Excel)"
[CPLX1xlsx]: https://www.eurocontrol.int/performance/data/download/xls/Traffic_Complexity_Scores_2.xlsx "CPLX (Excel)"
[CPLXcsv]:   /404/ "CPLX (CSV)"
[CPLXmeta]:  /reference/dataset/traffic-complexity-score/ "CPLX (Meta)"
[CPLXbada]:  /acronym/bada/ "Base of Aircraft Data"




## <img id="eco" src="/images/prcq-economics.png" width="50" height="50" alt="Economics"> Economics

| Data description                                                     | Period                                                                          | {{< excel_i >}}                | {{< csv_i >}} |  Info                        |     |
|----------------------------------------------------------------------|---------------------------------------------------------------------------------|--------------------------------|---------------|------------------------------|-----|
| ACE operational data<br><small>Monthly ACE operational data</small>  | {{< getdata "dwnld" "ace_opt_beg" >}} - {{< getdata "dwnld" "ace_opt_end" >}}   | [{{< dwnld_i >}}][ACExlsx]     |               | [{{< info_i >}}][ACEurl]     |     |
| ACE operational data<br><small>Yearly ACE operational data</small>   | {{< getdata "dwnld" "ace_year_end" >}}                                          | [{{< dwnld_i >}}][ACEyearxlsx] |               | [{{< info_i >}}][ACEyearurl] |     |
| ANSPs financial data<br><small>Yearly ANSPs financial data</small>   | {{< getdata "dwnld" "ansp_fin_beg" >}} - {{< getdata "dwnld" "ansp_fin_end" >}} | [{{< dwnld_i >}}][anspfinxlsx] |               | [{{< info_i >}}][anspfinurl] |     |

[ACExlsx]: https://www.eurocontrol.int/performance/data/download/xls/ACE_Monthly_Operational_Data.xlsx "ACE Month (Excel)"
[ACEcsv]:  /404/ "ACE Month (CSV)"
[ACEmeta]: /reference/dataset/ace-monthly-operational-data/ "ACE Month (Meta)"
[ACEurl]:  https://www.eurocontrol.int/publication/eurocontrol-specification-economic-information-disclosure "ACE specs"

[ACEyearxlsx]: https://www.eurocontrol.int/performance/data/download/xls/ACE_Yearly_Operational_Data.xlsx "ACE Year (Excel)"
[ACEyearcsv]:  /404/ "ACE Year (CSV)"
[ACEyearmeta]: /reference/dataset/ace-monthly-operational-data/ "ACE Year (Meta)"
[ACEyearurl]:  https://www.eurocontrol.int/publication/eurocontrol-specification-economic-information-disclosure "ACE specs"

[anspfinxlsx]: https://www.eurocontrol.int/performance/data/download/xls/ANSP_Financial_Data.xlsx "ANSPs Financial (Excel)"
[anspfincsv]:  /404/ "ACE Year (CSV)"
[anspfinmeta]: /404/ "ANSP Financial (Meta)"
[anspfinurl]:  https://ansperformance.eu/economics/finance/guide/ "Financial Dashboard Guide"
<br>

## <img id="opdi" src="/images/prcq_opdi.png" width="50" height="50" alt="Open Performance Data Initiative"> Open Performance Data Initiative (OPDI)

| Data Description                                                  | Period         | {{< excel_i >}} | {{< csv_i >}} | {{< parquet_i >}}                      | Info                          |
|-------------------------------------------------------------------|----------------|-----------------|---------------|----------------------------------------|-------------------------------|
| Flight list data<br><small>A flight list extracted from OpenSky Network ADS-B data</small>       | {{< getdata "dwnld" "opdi_beg" >}} - {{< getdata "dwnld" "opdi_end" >}} |                 |               | [{{< dwnld_i >}}][flightlistparquet]   | [{{< info_i >}}][flightlisturl]   |
| Flight event data<br><small>Various flight events extracted from OpenSky Network ADS-B data</small>     | {{< getdata "dwnld" "opdi_beg" >}} - {{< getdata "dwnld" "opdi_end" >}} |                 |               | [{{< dwnld_i >}}][flighteventparquet]  | [{{< info_i >}}][flighteventurl]  |
| Measurement data<br><small>Measurements of e.g., time & distance which are to be associated with the flight events</small>       | {{< getdata "dwnld" "opdi_beg" >}} - {{< getdata "dwnld" "opdi_end" >}} |                 |               | [{{< dwnld_i >}}][measurementparquet]  | [{{< info_i >}}][measurementurl]  |

[flightlistparquet]: https://www.opdi.aero/flight-list-data
[flighteventparquet]: https://www.opdi.aero/flight-event-data
[measurementparquet]: https://www.opdi.aero/measurement-data

[flightlisturl]: https://www.opdi.aero/data
[flighteventurl]: https://www.opdi.aero/data
[measurementurl]: https://www.opdi.aero/data


{{< excel_i >}} = Excel file.<br>
{{< csv_i >}} = CSV file.<br>
{{< parquet_i >}} = Parquet file(s).<br>
{{< dwnld_i >}} = dataset download.<br>
{{< info_i >}}  = info on dataset.<br>
{{< attn_i >}}  = not (yet?) available.<br>


<div class="container text-center">
{{< subscribe-button >}}<br>

[Read our Privacy protection statement](/about/privacy/)
</div>


<style>
i.fa.pru {color: #337ab7;}
table {
  width: 100% !important;
}

td {
/*  white-space: nowrap !important; */
  padding-left: 0.5em;
  padding-right: 0.5em;
}

th:nth-child(1) {
width: auto;
}

th:nth-child(2) {
width: 11em !important;
}

th:nth-child(3) {
width: 3em !important;
}

th:nth-child(4) {
width: 4em !important;
}

th:nth-child(5) {
width: 4em !important;
}

th:nth-child(6) {
width: 14em !important;
}


.h2 {
  margin-top: inherit;
}
</style>
