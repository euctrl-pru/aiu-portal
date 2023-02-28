/*jslint browser: true */
/*globals json2csv, d3, Blob, saveAs, queue, crossfilter, dc, buildFilter, Spinner */
(function () {
    "use strict";
    var dataFile    = 'hfe.json', // HACK: It's CSV, but GitHub Pages only gzip's JSON at the moment.)
        errfield = d3.select("#errorfield"),
        target = document.getElementById('hfe-data-table'),
        spinner = new Spinner().spin(target);

    // define what and how filtered data is to be saved
    function filteredCSV(data) {
        var fields = [
            "YEAR",
            "MONTH_NUM",
            "MONTH_MON",
            "ENTRY_DATE",
            "ENTITY_NAME",
            "ENTITY_TYPE",
            "TYPE_MODEL",
            "DIST_FLOWN_KM",
            "DIST_DIRECT_KM",
            "DIST_ACHIEVED_KM"
        ];

        json2csv({ data: data, fields: fields }, function (err, csv) {
            if (err) {
                errfield.classed();
                errfield.log(err);
            }
            var blob = new Blob([csv], {type: "text/csv"});
            saveAs(blob, "horizontal_flight_efficiency.csv");
        });
    }

    function conditionData(hfe) {
        var fullDateFormat = d3.time.format("%Y-%m-%dT%H:%M:%SZ");
        hfe.forEach(function (d) {
            d.YEAR = +d.YEAR;
            d.MONTH_NUM = +d.MONTH_NUM;
            // ENTRY_DATE stays like read, for CSV save not having to format it.
            d.date = fullDateFormat.parse(d.ENTRY_DATE);
            d.ENTITY_NAME = d.ENTITY_NAME ? d.ENTITY_NAME.trim() : '';
            d.ENTITY_NAME = d.ENTITY_NAME.length ? d.ENTITY_NAME : 'ZZZ';
            d.ENTITY_TYPE = d.ENTITY_TYPE ? d.ENTITY_TYPE.trim() : '';
            d.ENTITY_TYPE = d.ENTITY_TYPE.length ? d.ENTITY_TYPE : 'ZZZ';
            d.DIST_FLOWN_KM = d.DIST_FLOWN_KM ? +d.DIST_FLOWN_KM : 0;
            d.DIST_DIRECT_KM = d.DIST_DIRECT_KM ? +d.DIST_DIRECT_KM : 0;
            d.DIST_ACHIEVED_KM = d.DIST_ACHIEVED_KM ? +d.DIST_ACHIEVED_KM : 0;
        });
        return hfe;
    }

    function buildTable(hfe) {
        var xf = crossfilter(hfe),
            all = xf.groupAll(),
            hfeDate = xf.dimension(function (d) { return d.date; }),

            hfeYear = xf.dimension(function (d) { return d.YEAR; }),
            hfeYearGroup = hfeYear.group(Math.floor),

            hfeEntity = xf.dimension(function (d) { return d.ENTITY_NAME; }),
            hfeEntityGroup = hfeEntity.group(),

            hfeModel = xf.dimension(function (d) { return d.TYPE_MODEL; }),
            hfeModelGroup = hfeModel.group(),
            // utils
            format = d3.format('02d'),
            dataTable;


        buildFilter("#hfe-year", "All Years", hfeYear, hfeYearGroup);
        buildFilter("#hfe-entity", "All Entities", hfeEntity, hfeEntityGroup);
        buildFilter("#hfe-model", "All Profile Models", hfeModel, hfeModelGroup);

        spinner.stop();
        errfield.classed("hidden", true);


        // create a table to preview (a subset of) the filtered values
        dataTable = dc.dataTable('#hfe-data-table')
            .dimension(hfeDate)
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
                    label: 'Date',
                    format: function (d) {
                        return d.ENTRY_DATE;
                    }
                },
                {
                    label: 'Entity',
                    format: function (d) {
                        return d.ENTITY_NAME;
                    }
                },
                "ENTITY_TYPE",
                "TYPE_MODEL",
                "DIST_FLOWN_KM",
                "DIST_DIRECT_KM",
                "DIST_ACHIEVED_KM"
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
            $("#hfe-download").click(function () {
                filteredCSV(hfeYear.top(Infinity));
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
