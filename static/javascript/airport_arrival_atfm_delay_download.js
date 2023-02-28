/*jslint browser: true */
/*globals json2csv, d3, Blob, saveAs, queue, crossfilter, dc, buildFilter, Spinner */
(function () {
    "use strict";
    var dataFile    = 'apt_dly.json', // HACK: It's CSV, but GitHub Pages only gzip's JSON at the moment.)
        errfield = d3.select("#errorfield"),
        target = document.getElementById('arr-data-table'),
        spinner = new Spinner().spin(target);

    // define what and how filtered data is to be saved
    function filteredCSV(data) {
        var fields = [
            "YEAR",
            "MONTH_NUM",
            "MONTH_MON",
            "FLT_DATE",
            "APT_ICAO",
            "APT_NAME",
            "STATE_NAME",
            "FLT_ARR_1",
            "DLY_APT_1",
            "FLT_ARR_1_DLY",
            "FLT_ARR_1_DLY_15",
            "DLY_APT_ARR_A_1",
            "DLY_APT_ARR_C_1",
            "DLY_APT_ARR_D_1",
            "DLY_APT_ARR_E_1",
            "DLY_APT_ARR_G_1",
            "DLY_APT_ARR_I_1",
            "DLY_APT_ARR_M_1",
            "DLY_APT_ARR_N_1",
            "DLY_APT_ARR_O_1",
            "DLY_APT_ARR_P_1",
            "DLY_APT_ARR_R_1",
            "DLY_APT_ARR_S_1",
            "DLY_APT_ARR_T_1",
            "DLY_APT_ARR_V_1",
            "DLY_APT_ARR_W_1",
            "DLY_APT_ARR_NA_1"
        ];

        json2csv({ data: data, fields: fields }, function (err, csv) {
            if (err) {
                errfield.classed();
                errfield.log(err);
            }
            var blob = new Blob([csv], {type: "text/csv"});
            saveAs(blob, "arrival_atfcm_delay.csv");
        });
    }

    function conditionData(arr) {
        var fullDateFormat = d3.time.format("%Y-%m-%dT%H:%M:%SZ");

        arr.forEach(function (d) {
            d.YEAR = +d.YEAR;
            d.MONTH_NUM = +d.MONTH_NUM;
            // d.FLT_DATE stays a string as read from file
            d.date = fullDateFormat.parse(d.FLT_DATE);
            d.APT_NAME = d.APT_NAME ? d.APT_NAME.trim() : 'ZZZ';
            d.APT_NAME = d.APT_NAME.length ? d.APT_NAME : 'ZZZ';
            d.APT_ICAO = d.APT_ICAO || 'ZZZZ';
            d.STATE_NAME = d.STATE_NAME ? d.STATE_NAME.trim() : '';
            d.STATE_NAME = d.STATE_NAME.length ? d.STATE_NAME : 'ZZZ';
            d.FLT_ARR_1 = d.FLT_ARR_1 ? +d.FLT_ARR_1 : 0;
            d.DLY_APT_1 = d.DLY_APT_1 ? +d.DLY_APT_1 : 0;
            d.DLY_APT_ARR_A_1 =  d.DLY_APT_ARR_A_1 == 'NA' ? '' : d.DLY_APT_ARR_A_1 ? +d.DLY_APT_ARR_A_1 : 0;
            d.DLY_APT_ARR_C_1 =  d.DLY_APT_ARR_C_1 == 'NA' ? '' : d.DLY_APT_ARR_C_1 ? +d.DLY_APT_ARR_C_1 : 0;
            d.DLY_APT_ARR_D_1 =  d.DLY_APT_ARR_D_1 == 'NA' ? '' : d.DLY_APT_ARR_D_1 ? +d.DLY_APT_ARR_D_1 : 0;
            d.DLY_APT_ARR_E_1 =  d.DLY_APT_ARR_E_1 == 'NA' ? '' : d.DLY_APT_ARR_E_1 ? +d.DLY_APT_ARR_E_1 : 0;
            d.DLY_APT_ARR_G_1 =  d.DLY_APT_ARR_G_1 == 'NA' ? '' : d.DLY_APT_ARR_G_1 ? +d.DLY_APT_ARR_G_1 : 0;
            d.DLY_APT_ARR_I_1 =  d.DLY_APT_ARR_I_1 == 'NA' ? '' : d.DLY_APT_ARR_I_1 ? +d.DLY_APT_ARR_I_1 : 0;
            d.DLY_APT_ARR_M_1 =  d.DLY_APT_ARR_M_1 == 'NA' ? '' : d.DLY_APT_ARR_M_1 ? +d.DLY_APT_ARR_M_1 : 0;
            d.DLY_APT_ARR_N_1 =  d.DLY_APT_ARR_N_1 == 'NA' ? '' : d.DLY_APT_ARR_N_1 ? +d.DLY_APT_ARR_N_1 : 0;
            d.DLY_APT_ARR_O_1 =  d.DLY_APT_ARR_O_1 == 'NA' ? '' : d.DLY_APT_ARR_O_1 ? +d.DLY_APT_ARR_O_1 : 0;
            d.DLY_APT_ARR_P_1 =  d.DLY_APT_ARR_P_1 == 'NA' ? '' : d.DLY_APT_ARR_P_1 ? +d.DLY_APT_ARR_P_1 : 0;
            d.DLY_APT_ARR_R_1 =  d.DLY_APT_ARR_R_1 == 'NA' ? '' : d.DLY_APT_ARR_R_1 ? +d.DLY_APT_ARR_R_1 : 0;
            d.DLY_APT_ARR_S_1 =  d.DLY_APT_ARR_S_1 == 'NA' ? '' : d.DLY_APT_ARR_S_1 ? +d.DLY_APT_ARR_S_1 : 0;
            d.DLY_APT_ARR_T_1 =  d.DLY_APT_ARR_T_1 == 'NA' ? '' : d.DLY_APT_ARR_T_1 ? +d.DLY_APT_ARR_T_1 : 0;
            d.DLY_APT_ARR_V_1 =  d.DLY_APT_ARR_V_1 == 'NA' ? '' : d.DLY_APT_ARR_V_1 ? +d.DLY_APT_ARR_V_1 : 0;
            d.DLY_APT_ARR_W_1 =  d.DLY_APT_ARR_W_1 == 'NA' ? '' : d.DLY_APT_ARR_W_1 ? +d.DLY_APT_ARR_W_1 : 0;
            d.DLY_APT_ARR_NA_1 = d.DLY_APT_ARR_NA_1 == 'NA' ? '' : d.DLY_APT_ARR_NA_1 ? +d.DLY_APT_ARR_NA_1 : 0;
            d.FLT_ARR_1_DLY =    d.FLT_ARR_1_DLY == 'NA' ? '' : d.FLT_ARR_1_DLY ? +d.FLT_ARR_1_DLY : 0;
            d.FLT_ARR_1_DLY_15 = d.FLT_ARR_1_DLY_15 == 'NA' ? '' : d.FLT_ARR_1_DLY_15 ? +d.FLT_ARR_1_DLY_15 : 0;
        });

        return arr;
    }


    function buildTable(arr) {

        var xf = crossfilter(arr),
            all = xf.groupAll(),
            arrDate = xf.dimension(function (d) { return d.date; }),
            // year grouping
            arrYear = xf.dimension(function (d) { return d.YEAR; }),
            arrYearGroup = arrYear.group(Math.floor),
            // country grouping
            arrCountry = xf.dimension(function (d) { return d.STATE_NAME; }),
            arrCountryGroup = arrCountry.group(),
            // airport grouping
            arrAirport = xf.dimension(function (d) { return d.APT_ICAO; }),
            arrAirportGroup = arrAirport.group(),
            // utils
            format = d3.format('02d'),
            dataTable;


        buildFilter("#arr-year", "All Years", arrYear, arrYearGroup);
        buildFilter("#arr-country", "All Countries", arrCountry, arrCountryGroup);
        buildFilter("#arr-apt", "All Airports", arrAirport, arrAirportGroup);

        spinner.stop();
        errfield.classed("hidden", true);


        // create a table to preview (a subset of) the filtered values
        dataTable = dc.dataTable('#arr-data-table')
            .dimension(arrDate)
            .group(function (d) {
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
                    label: 'Country',
                    format: function (d) {
                        return d.STATE_NAME;
                    }
                },
                "FLT_DATE",
                "APT_ICAO",
                "APT_NAME",
                "FLT_ARR_1",
                "FLT_ARR_1_DLY",
                "FLT_ARR_1_DLY_15",
                "DLY_APT_1",
                "DLY_APT_ARR_A_1",
                "DLY_APT_ARR_C_1",
                "DLY_APT_ARR_D_1",
                "DLY_APT_ARR_E_1",
                "DLY_APT_ARR_G_1",
                "DLY_APT_ARR_I_1",
                "DLY_APT_ARR_M_1",
                "DLY_APT_ARR_N_1",
                "DLY_APT_ARR_O_1",
                "DLY_APT_ARR_P_1",
                "DLY_APT_ARR_R_1",
                "DLY_APT_ARR_S_1",
                "DLY_APT_ARR_T_1",
                "DLY_APT_ARR_V_1",
                "DLY_APT_ARR_W_1",
                "DLY_APT_ARR_NA_1"
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
                some: '<strong>%filter-count</strong> selected out of <strong>%total-count</strong> records' +
                    ' (only a max of <em>' + dataTable.size() + '</em> shown below.)',
                all: 'All <strong>%total-count</strong> records selected' +
                    ' (only a max of <em>' + dataTable.size() + '</em> shown below.)'
            });


        dc.renderAll();

        // action linked to 'Download button'
        $(document).ready(function () {
            $("#arr-download").click(function () {
                filteredCSV(arrYear.top(Infinity));
            });
        });

    }


    function ready(error, data) {
        if (error) {
            errfield.text("Error:" + error);
            spinner.stop();
        } else {
            errfield.classed("hidden", true);
            buildTable(conditionData(data));
        }
    }

    d3.queue()
        .defer(d3.csv, dataFile)
        .await(ready);
}());
