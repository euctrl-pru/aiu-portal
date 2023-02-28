---
title: Modification of the ATFM delay calculation (NM release 20.0)
slug: atfm-delay-calculation
---
<style>
img + em {
text-align: center;
}

img + em:before {
content: ' ';
display: block;
}
</style>


## Background

Air Navigation Service Providers (ANSPs) noticed that the use of the Ready
Message (REA) - whilst attempting to improve punctuality for aircraft – could
result in artificial changes to the computed ATFM delay for individual
flights and for the ANSP that has requested the regulation.

The ANSPs brought this to the attention of the Network Management Board (NMB).
The ANSPs, together with the airspace users and the Network Manager reviewed the
existing situation and developed a more accurate process which avoids artificial
changes to the computed ATFM delay when a REA message is used.

The more accurate process was presented to the NMB and approved in March 2015
for implementation with NM software release 20.0 on April 04 2016.

## NM software version 20.0 related changes (04 April 2016)

The changes implemented with the release of NM software version 20.0 on 04 April
2016 reduce the overall level of computed ATFM delay. The changes are described
in more detail in the relevant [NM Release presentation][NM20-rn].

## Post Operations Performance Adjustment Process

The Post Ops Performance Adjustment Process allows operational stakeholders to notify
national and European authorities of issues that relate to ATFM delay measurement,
classification and assignment. It is a means of enhancing operational ATFM delay data
used in the performance scheme (Regulation (EU) 390) – and thus a means of compliance
with Article 21(3).

More information is available from the [respective NM website][post-ops].

## Impact on this webpage

The ATFM delay related graphs shown on this web page and data in the
[download area](/data/performancearea/) take the change in
methodology as of April 2016 into account.

In the ATFM delay file downloads, the computation method is indicated in the column "ATFM version"

| ATFM version 	| REA message adjustment    	| Post ops adjustment 	|
|--------------	|---------------------------	|---------------------	|
| Version 1    	| No                        	| No                  	|
| Version 2    	| Yes                       	| No                  	|
| Version 3    	| Yes (as of 04 April 2016) 	| Yes                 	|


[NM20-rn]: /library/NM_20_FB750_Delay_Calculation_improvements.pdf "NM 20 Release Notes: Delay calculation improvements"
[post-ops]: https://www.eurocontrol.int/service/post-operations-performance-adjustment "Post Operations Performance Adjustment Process"
