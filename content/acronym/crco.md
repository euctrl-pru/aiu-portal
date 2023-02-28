---
title: CRCO - Central Route Charges Office
slug: crco
---

Airspace users which fly in the controlled airspace of EUROCONTROL’s Member States
pay for the air traffic services they use.

EUROCONTROL's Central Route Charges Office (CRCO) charges airspace users
for these services on behalf of the Member States.

The CRCO calculates the route charges due to the Member States for the
services provided, bills the airspace users and distributes the route
charges to the States concerned.


<div id="observablehq-viewof-mY-25dc0def"></div>
<div id="observablehq-map-25dc0def"></div>

<script type="module">
import {Runtime, Inspector} from "https://cdn.jsdelivr.net/npm/@observablehq/runtime@4/dist/runtime.js";
import define from "https://api.observablehq.com/@espinielli/central-route-charging-office-zones-and-rates.js?v=3";
new Runtime().module(define, name => {
  if (name === "map") return new Inspector(document.querySelector("#observablehq-map-25dc0def"));
  if (name === "viewof mY") return new Inspector(document.querySelector("#observablehq-viewof-mY-25dc0def"));
  return ["rates","labelled_rates","crco_charging_zones","d_rates","year_month","file_url","current_month"].includes(name);
});
</script>


## See Also

* {{< a_blank_ectrl "CRCO" "https://www.eurocontrol.int/crco" >}}

