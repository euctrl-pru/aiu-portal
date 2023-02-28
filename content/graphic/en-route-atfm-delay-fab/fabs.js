/*jslint browser: true, devel: true */
var d3, queue, vis, params, topojson;
(function () {
  "use strict";
  vis = {};
  var width, height,
      chart, svg, active, background,
      path,
      currentYear;

  // general design from
  // http://www.jeromecukier.net/blog/2013/11/20/getting-beyond-hello-world-with-d3/
  vis.init = function (params) {
    vis.params = params || {};

    chart = d3.select(vis.params.chart || "#chart"); // placeholder div for svg
    width = vis.params.width || 500;
    height = vis.params.height || 450;
    active = d3.select(null);

    svg = chart.selectAll("svg")
      .data([{width: width, height: height}]).enter()
      .append("svg");
    svg.attr({
      width:  function (d) { return d.width; },
      height: function (d) { return d.height; }
    });

    background = svg.selectAll("rect.background")
      .data([{}]).enter()
      .append("rect")
      .classed("background", true);

    d3.select("#year-controls")
      .style("right", "20px")
      .style("bottom", "1px");
    // vis.init can be re-ran to pass different height/width values
    // to the svg. this doesn't create new svg elements.


    vis.loaddata(vis.params);
  };

  function ready(error, fabs, world, wnames, trafficdelays) {
    if (error) {
      console.error(error);
    }

    var fabsInfo = [
      {"id": "BALTIC",  "name": "Baltic FAB"},
      {"id": "BLUEMED", "name": "BLUE MED FAB"},
      {"id": "DANUBE",  "name": "DANUBE FAB"},
      {"id": "DKSE",    "name": "DK-SE FAB"},
      {"id": "FABCE",   "name": "FAB CE (SES RP2)"},
      {"id": "FABEC",   "name": "FABEC"},
      {"id": "NEFAB",   "name": "NEFAB"},
      {"id": "SWFAB",   "name": "SW FAB"},
      {"id": "UKEI",    "name": "UK-Ireland FAB"}
    ];

    function idxForName(target) {
      return function(idx, item, i) {
        return item.name === target ? i : idx;
      };
    }

    vis.fabs = fabs;
    vis.world = world;
    vis.wnames = wnames;

    trafficdelays.forEach(function(d) {
      var obj_idx = fabsInfo.reduce(idxForName(d.ENTITY_NAME), -1);
      if (obj_idx === -1) {
        console.log(d);
        console.log("FAB name NOT found!!!!");
      }
      else {
        d.YEAR = +d.YEAR;
        d.id = fabsInfo[obj_idx].id;
        d.flt = +d.flt;
        d.dly = +d.dly;
        d.rate = d.flt == 0 ? 0 : d.dly / d.flt;
      }
    });
    vis.trafficdelays = trafficdelays;

    vis.draw(vis.params);
  }

  vis.loaddata = function (params) {
    if (!params) { params = {}; }

    // if `params.refresh` is set/true forces the browser to reload the file
    // and not use the cached version due to URL being different (but the filename is the same)
    var fabs = (params.fabs || "fabs.json") + (params.refresh ? ("#" + Math.random()) : "");
    var world = (params.world || "world-50m.json") + (params.refresh ? ("#" + Math.random()) : "");
    var names = (params.worldnames || "world-country-names.tsv") + (params.refresh ? ("#" + Math.random()) : "");
    var trafficdelays = (params.trafficdelays || "monthly-ert-dly-fab-fir.csv") + (params.refresh ? ("#" + Math.random()) : "");

    queue()
      .defer(d3.json, fabs)
      .defer(d3.json, world)
      .defer(d3.tsv, names)
      .defer(d3.csv, trafficdelays)
      .await(ready);
  };


  vis.draw = function (params) {
    // make stuff here!
    var pars = params || {},
        scale = pars.scale || 600,
		    cLon = pars.centerLon || 10,
    		cLat = pars.centerLat || 51.5,
        projection = d3.geo.albers()
          .center([cLon, cLat])
          .rotate([4.4, 0])
          .parallels([50, 60])
          .scale(scale)
          .translate([width / 2, height / 2]),
        fabs = topojson.feature(vis.fabs, vis.fabs.objects.fabs).features,

        tooltip = d3.select("#tooltip").classed("hidden", true),
        tiplabel = d3.select("#countryname").append("tspan"),
        graticule = d3.geo.graticule(),

        land = topojson.feature(vis.world, vis.world.objects.land),
        countries = topojson.feature(vis.world, vis.world.objects.countries).features,
        borders = topojson.mesh(vis.world, vis.world.objects.countries, function (a, b) { return a.id !== b.id; }),
        country;

    // capture selected year
    currentYear = d3.select("#year-controls input[name=mode]:checked").property("value");
    d3.selectAll("#year-controls input[name=mode]").on("change", function() {
      currentYear = this.value;
      update(this.value);
    });


    var twodecimals = d3.format(".2n");

    // range of values for scale
    function getDelayRange(year) {
      var min = Infinity, max = -Infinity;
      var yearlyDelays = vis.trafficdelays.filter(function(d) {
        return true;
      }).map(function(d) {return d.rate;});

      return [d3.min(yearlyDelays), d3.max(yearlyDelays)];
    }

    // selected from http://colorbrewer2.org/ :
    //  * sequencial data,
    //  * 5 classes,
    //  * colorblind safe,
    //  * printer friendly
    // ==> 5-class GnBu
    // see also https://bl.ocks.org/mbostock/5577023
    var qClasses = 5;
    var colorPalette = colorbrewer.GnBu[qClasses];
    var quantize = d3.scale.quantize()
          .domain(getDelayRange(currentYear))
          .range(colorPalette);


    function getColor(val) {
      return quantize(val);
    }

    function getDelay(id, year) {
      var val = vis.trafficdelays.filter(function(d) {
        return d.YEAR == year && d.id === id;
      });
      return val[0].rate;
    }

    path = d3.geo.path()
      .projection(projection);

    countries.forEach(function (d) {
      vis.wnames.some(function (n) {
        if (+d.id === +n.id) {
          d.name = n.name;
          return d.name;
        }
        return null;
      });
    });

    // update tooltip position
    svg.on("mousemove", function () {
      tooltip.style("top", (event.pageY + 16) + "px").style("left", (event.pageX + 10) + "px");
      return true;
    });

    svg.append("path")
      .datum(graticule)
      .attr("class", "graticule")
      .attr("d", path);


    svg.append("g")
      .attr("class", "legendQuant")
      .attr("transform", "translate(20," + height/3 + ")");

    var legend = d3.legend.color()
          .labelFormat(d3.format(".2f"))
          .title(currentYear + " situation")
          .scale(quantize);

    svg.select(".legendQuant")
      .call(legend);

    country = svg.selectAll(".country")
      .data(countries)
      .enter().insert("path", ".graticule")
      .attr("class", function (d) {return "country country" + d.id; })
      .attr("d", path)
      .text(function (d) { return d.id; })
      .on("mouseover", function (d, i) {
        d3.select(this).style({'stroke-opacity': 1, 'stroke': '#F00'});
        // http://stackoverflow.com/questions/17917072/#answer-17917341
        // d3.select(this.parentNode.appendChild(this)).style({'stroke-opacity':1,'stroke':'#F00'});
        if (d.id) {
          tooltip.classed("hidden", false);
          tiplabel.text(d.name);
        }
      })
      .on("mouseout", function () {
        this.style.stroke = "#000";
        tooltip.classed("hidden", true);
      })
      .on("mousedown.log", function (d) {
        console.log("id=" + d.id + "; name=" + d.name + "; centroid=[" + path.centroid(d) + "] px.");
      });


    var fabsMap = svg.selectAll(".fab")
          .data(fabs)
          .enter().append("path", ".graticule")
          .attr("d", path)
          .attr("class", function(d) { return "fab "; })
          .attr("fill", function(d) { return getColor(getDelay(d.properties.id, currentYear)); })
    // .attr("class", function(d) {return "fab " + d.properties.id + " " + getColor(getDelay(d.properties.id, currentYear));})
          .on("mouseover", function (d) {
            d3.select(this)
              .style("stroke", "red");
            tooltip.classed("hidden", false);
            tiplabel.html(d.properties.id +
                          "<br> avg delay per flight: "
                          + "<strong>" + twodecimals(getDelay(d.properties.id, currentYear)) + "</strong>"
                         );
          })
          .on("mouseleave", function (d) {
            d3.select(this).style("stroke", "yellow");
            tooltip.classed("hidden", true);
          })
          .on("mousedown.log", function (d) {
            console.log("id=" + d.properties.id + "; centroid=[" + path.centroid(d) + "] px.");
          });


    // Updates the display to show the specified year.
    function update(year) {
      currentYear = year;

      svg.select(".legendTitle")
        .text(currentYear + " situation");

      fabsMap.transition()  //select all the fabs and prepare for a transition to new values
        .duration(750)  // give it a smooth time period for the transition
        .attr("fill", function(d) {
          return getColor(getDelay(d.properties.id, year));});
    }
  };
}());
