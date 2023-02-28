(function() {
   var dataFile    = 'ace_ansp.csv';
   var years; // the years in the dataset
   var ansps; // the ansp names in the dataset
   var data;
   var loading = d3.selectAll("#loading");

   function filteredCSV(data) {
      var fields = [
         'YEAR',
         'MONTH_NUM',
         'ANSP_NAME',
         'FLT_1',
         'DIST_KM_1',
         'DUR_MIN_1',
         'FLT_DLY_1',
         'FLT_DLY_15_1',
         'DLY_1',
         'DLY_15_1',
         'FLT_DLY_APT_1',
         'FLT_DLY_APT_15_1',
         'DLY_APT_1',
         'DLY_APT_15_1',
         'FLT_DLY_ERT_1',
         'FLT_DLY_ERT_15_1',
         'DLY_ERT_1',
         'DLY_ERT_15_1',
         'DLY_ERT_A_1',
         'DLY_ERT_C_1',
         'DLY_ERT_D_1',
         'DLY_ERT_E_1',
         'DLY_ERT_G_1',
         'DLY_ERT_I_1',
         'DLY_ERT_M_1',
         'DLY_ERT_N_1',
         'DLY_ERT_O_1',
         'DLY_ERT_P_1',
         'DLY_ERT_R_1',
         'DLY_ERT_S_1',
         'DLY_ERT_T_1',
         'DLY_ERT_V_1',
         'DLY_ERT_W_1',
         'DLY_ERT_NA_1'
      ];

      json2csv({ data: data, fields: fields }, function(err, csv) {
         if (err) console.log(err);
         var blob = new Blob([csv], {type: "text/csv"});
         saveAs(blob, "ace_ansp.csv");
      });
   }


   queue() 
      .defer(d3.csv, dataFile) 
      .await(function(error, ace) {
         var dateFormat = d3.time.format("%m-%Y");

         ace.forEach(function(d, i) {
            d.YEAR = +d.YEAR;
            d.MONTH_NUM = +d.MONTH_NUM;
            d.date = dateFormat.parse(d.MONTH_NUM + "-" + d.YEAR);
            d.FLT_1 = +d.FLT_1;
            d.DIST_KM_1 = +d.DIST_KM_1;
            d.DUR_MIN_1 = +d.DUR_MIN_1;
            d.FLT_DLY_1 = d.FLT_DLY_1 ? +d.FLT_DLY_1 : 0;
            d.FLT_DLY_15_1 = d.FLT_DLY_15_1 ? +d.FLT_DLY_15_1 : 0;
            d.DLY_1 = d.DLY_1 ? +d.DLY_1 : 0;
            d.DLY_15_1 = d.DLY_15_1 ? +d.DLY_15_1 : 0;
            d.FLT_DLY_APT_1 = d.FLT_DLY_APT_1 ? +d.FLT_DLY_APT_1 : 0;
            d.FLT_DLY_APT_15_1 = d.FLT_DLY_APT_15_1 ? +d.FLT_DLY_APT_15_1 : 0;
            d.DLY_APT_1 = d.DLY_APT_1 ? +d.DLY_APT_1 : 0;
            d.DLY_APT_15_1 = d.DLY_APT_15_1 ? +d.DLY_APT_15_1 : 0;
            d.FLT_DLY_ERT_1 = d.FLT_DLY_ERT_1 ? +d.FLT_DLY_ERT_1 : 0;
            d.FLT_DLY_ERT_15_1 = d.FLT_DLY_ERT_15_1 ? +d.FLT_DLY_ERT_15_1 : 0;
            d.DLY_ERT_1 = d.DLY_ERT_1 ? +d.DLY_ERT_1 : 0;
            d.DLY_ERT_15_1 = d.DLY_ERT_15_1 ? +d.DLY_ERT_15_1 : 0;
            d.DLY_ERT_A_1 = d.DLY_ERT_A_1 ? +d.DLY_ERT_A_1 : 0;
            d.DLY_ERT_C_1 = d.DLY_ERT_C_1 ? +d.DLY_ERT_C_1 : 0;
            d.DLY_ERT_D_1 = d.DLY_ERT_D_1 ? +d.DLY_ERT_D_1 : 0;
            d.DLY_ERT_E_1 = d.DLY_ERT_E_1 ? +d.DLY_ERT_E_1 : 0;
            d.DLY_ERT_G_1 = d.DLY_ERT_G_1 ? +d.DLY_ERT_G_1 : 0;
            d.DLY_ERT_I_1 = d.DLY_ERT_I_1 ? +d.DLY_ERT_I_1 : 0;
            d.DLY_ERT_M_1 = d.DLY_ERT_M_1 ? +d.DLY_ERT_M_1 : 0;
            d.DLY_ERT_N_1 = d.DLY_ERT_N_1 ? +d.DLY_ERT_N_1 : 0;
            d.DLY_ERT_O_1 = d.DLY_ERT_O_1 ? +d.DLY_ERT_O_1 : 0;
            d.DLY_ERT_P_1 = d.DLY_ERT_P_1 ? +d.DLY_ERT_P_1 : 0;
            d.DLY_ERT_R_1 = d.DLY_ERT_R_1 ? +d.DLY_ERT_R_1 : 0;
            d.DLY_ERT_S_1 = d.DLY_ERT_S_1 ? +d.DLY_ERT_S_1 : 0;
            d.DLY_ERT_T_1 = d.DLY_ERT_T_1 ? +d.DLY_ERT_T_1 : 0;
            d.DLY_ERT_V_1 = d.DLY_ERT_V_1 ? +d.DLY_ERT_V_1 : 0;
            d.DLY_ERT_W_1 = d.DLY_ERT_W_1 ? +d.DLY_ERT_W_1 : 0;
            d.DLY_ERT_NA_1 = d.DLY_ERT_NA_1 ? +d.DLY_ERT_NA_1 : 0;
         });

         var xf = crossfilter(ace);
         var all = xf.groupAll();
         var aceDate = xf.dimension(function(d){return d.date;});

         var aceYear = xf.dimension(function(d){return d.YEAR;});
         var aceYearGroup = aceYear.group(Math.floor);

         var aceAnsp = xf.dimension(function(d){return d.ANSP_NAME;});
         var aceAnspGroup = aceAnsp.group();


         // YEARS DROPDOWN
         // add an "All Years" item to the year dropdown menu
         d3.select("#ace-year")
            .append("option")
            .text("All Years")
            .attr("value", "-1");

         // fill the year dropdown menu with the available years from the dataset
         years = _.pluck(aceYearGroup.top(Infinity),"key");
         years = years.map(function(d,i){return {id: i, 'text': d};});
         $("#ace-year").select2({
            data: years,
            minimumResultsForSearch: Infinity
         });

         // call filterByYear when a new selection is made
         $("#ace-year").on("change", function() {
            filterByYear(this.value);
         });


         // ANSPs DROPDOWN
         // add an "All ANSPs" item to the ansps dropdown menu
         d3.select("#ace-ansp")
            .append("option")
            .text("All ANSPs")
            .attr("value", "-1");

         // fill the ansps dropdown menu with the available ansp names from the dataset
         ansps = _.pluck(aceAnspGroup.top(Infinity),"key");
         ansps = ansps.map(function(d,i){return {id: i, 'text': d};});
         // console.log(ansps);
         $("#ace-ansp").select2({
            data: ansps
         });

         // call filterByAnsp when a new selection is made
         $("#ace-ansp").on("change", function() {
            filterByAnsp(this.value);
         });

        loading.classed("hidden", true);

         // create a table to preview (a subset of) the filtered values
         var format = d3.format('02d');
         var dataTable = dc.dataTable('#ace-data-table')
            .dimension(aceDate)
            .group(function (d) {
               var format = d3.format('02d');
               return d.date.getFullYear() + '/' + format((d.date.getMonth() + 1));
            })
            .size(12) // (optional) max number of records to be shown, :default = 25
            .columns([
               {
                  label: 'YYYY/MM',
                  format: function (d) {
                   return d.date.getFullYear() + '/' + format((d.date.getMonth() + 1));
                  }
               },
               {
                  label: 'Unit Name',
                  format: function (d) {
                     return d.ANSP_NAME;
                  }
               },
               'FLT_1',
               'DIST_KM_1',
               'DUR_MIN_1',
               'FLT_DLY_1',
               'FLT_DLY_15_1',
               'DLY_1',
               'DLY_15_1',
               'FLT_DLY_APT_1',
               'FLT_DLY_APT_15_1',
               'DLY_APT_1',
               'DLY_APT_15_1',
               'FLT_DLY_ERT_1',
               'FLT_DLY_ERT_15_1',
               'DLY_ERT_1',
               'DLY_ERT_15_1',
               'DLY_ERT_A_1',
               'DLY_ERT_C_1',
               'DLY_ERT_D_1',
               'DLY_ERT_E_1',
               'DLY_ERT_G_1',
               'DLY_ERT_I_1',
               'DLY_ERT_M_1',
               'DLY_ERT_N_1',
               'DLY_ERT_O_1',
               'DLY_ERT_P_1',
               'DLY_ERT_R_1',
               'DLY_ERT_S_1',
               'DLY_ERT_T_1',
               'DLY_ERT_V_1',
               'DLY_ERT_W_1',
               'DLY_ERT_NA_1'
            ])
            .sortBy(function (d) {
               return d.date;
            })
            .order(d3.ascending);

         dc.dataCount('.dc-data-count')
            .dimension(xf)
            .group(all)
            // (optional) html, for setting different html for some records and all records.
            // .html replaces everything in the anchor with the html given using the following function.
            // %filter-count and %total-count are replaced with the values obtained.
            .html({
               some:'<strong>%filter-count</strong> selected out of <strong>%total-count</strong> records' +
               ' (only a max of <em>' + dataTable.size() + '</em> shown below.)',
               all:'All <strong>%total-count</strong> records selected'+
               ' (only a max of <em>' + dataTable.size() + '</em> shown below.)'
            });


         dc.renderAll();

         // TODO: finde a better place!
         // action linked to 'Download button'
         $(document).ready(function() {
            $("#ace-ansp-download").click(function() {
               filteredCSV(aceYear.top(Infinity));
            })
         });

         function filterByYear(val) {
            aceYear.filterAll();
            if (val == -1) {
            }
            else {
               aceYear.filter(function(d) {return d == +years[val].text});
            }
            dc.redrawAll();
         }

         function filterByAnsp(val) {
            aceAnsp.filterAll();
            if (val == -1) {
            }
            else {
               aceAnsp.filter(function(d) {return d === ansps[val].text});
            }
            dc.redrawAll();
         }
      });
})();
