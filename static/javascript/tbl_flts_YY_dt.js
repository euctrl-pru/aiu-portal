(function() {
  var dataFile    = 'ert_flt_ansp.tsv',
      errfield = d3.select("#errorfield"),
      target = document.getElementById('arr-data-table'),
      spinner = new Spinner().spin(target);

  queue()
    .defer(d3.tsv, dataFile)
    .await(ready);

  function ready(error, data) {
    if (error) {
      errfield.text("Error:" + error);
      spinner.stop();
    } else {
      errfield.classed("hidden", true);
      buildTable(conditionData(data));
    }
  }


  function ready() {
    $(document).ready(function() {
      $('#').DataTable( {
        data: dataSet,
        columns: [
          { title: "Name" },
          { title: "Position" },
          { title: "Office" },
          { title: "Extn." },
          { title: "Start date" },
          { title: "Salary" }
        ]
      } );
    });
  }
})();
