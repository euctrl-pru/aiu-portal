---
title: TDI - Turnaround Delay Indicator
slug: tdi
---

The Turnaround Delay Indicator (TDI) equals the [DDI-G][ddi-g] but neutralizes
early arrivals.
The actual arrival time is set to the scheduled arrival in case of an early
arrival.

$$
\mathrm{TDI} = \mathrm{Departure\ Delay} - 
\begin{cases}
0, & \mbox{if } \mbox{Inbound Delay} <= 0 \\\\
\mbox{Inbound Delay}, & \mbox{if } \mbox{Inbound Delay} > 0
\end{cases}
\ [min]
$$

## See Also

* [DDI-G][ddi-g]
* [GTO][gto]

[ddi-g]: {{< relref "ddi-g.md" >}} "DDI-G"
[gto]: {{< relref "gto.md" >}} "GTO"

