/*jslint browser: true */
/*globals _, $, d3, dc */
// build filter by year
// id: the DOM element ID
function buildFilter(id, allLabel, dim, dimGroup) {
  "use strict";
  // Dimension DROPDOWN
  // add an "All XXXX" item to the dropdown menu
  d3.select(id)
    .append("option")
    .text(allLabel)
    .attr("value", "-1");

  // fill the dimension dropdown menu with the available dims from the dataset
  /*jslint nomen:true */
  var dims = _.map(dimGroup.top(Infinity), "key");
  /*jslint nomen:false */
  dims.sort();
  dims = dims.map(function (d, i) { return {id: i, 'text': d}; });
  $(id).select2({
    data: dims,
    minimumResultsForSearch: Infinity
  });

  function filterByDim(val) {
    // console.log(val);
    dim.filterAll();
    if (+val !== -1) {
      dim.filter(function (d) { return d === dims[val].text; });
    }
    else {
      dim.filterAll();
      // console.log("selected '" + allLabel + "'.");
    }
    dc.redrawAll();
  }

  // call filterByYear when a new selection is made
  $(id).on("change", function () {
    filterByDim(this.value);
  });

}
