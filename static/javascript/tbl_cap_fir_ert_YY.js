var tbl_cap_fir_ert_YY = {};

(function() {

  function chart(baseurl) {
    var data;
    var twodecimals = d3.format(".2n");
    var integerFormatter = new google.visualization.NumberFormat({fractionDigits: 0, groupingSymbol: '' });
    var twodecimalFormatter = new google.visualization.NumberFormat({ fractionDigits: 2, groupingSymbol: '' });
    d3.text("/graphic/en-route-atfm-delay-fab/monthly-ert-dly-fab-fir.csv", function(error, text) {
      if (error) {
        console.log("tbl_cap_fir_ert_YY: Error reading file.");
        return;
      }

      var csvArray = d3.csv.parseRows(text, function (d, i) {
        if (i === 0) {
            return ["Year","FAB","Flights","Delay [min.]", "Avg. per Flight"];
        }
        d[0] = +d[0]; // YYYY
        d[2] = +d[2]; // # of flights
        d[3] = +d[3]; // total minutes of delay
        var avg = d[2] === 0 ? 0 : d[3] / d[2];
        return [
          d[0],
          d[1],
          d[2],
          d[3],
          twodecimals(avg)
        ];
      });

      data = new google.visualization.arrayToDataTable(csvArray);
      integerFormatter.format(data, 0);
      twodecimalFormatter.format(data, 4);
    });

    function dv() {
      // CAPACITY - En-route ATFM delays FAB (FIR) - TABLE
      var tbl = new google.visualization.ChartWrapper({
        chartType: 'Table',
        containerId: 'tbl_cap_fir_ert_YY',
        dataTable: data,
        options: {
            // allowHtml: true,
            width: 550,
            height: 480,
            sort: 'enable',
            sortColumn: 0,
            sortAscending: false
        },
          view: { columns: [0, 1, 2, 3, 4]}
      });
      tbl.draw();
    }

    google.setOnLoadCallback(dv);
  }

  tbl_cap_fir_ert_YY.chart = chart;

  return tbl_cap_fir_ert_YY;
})();