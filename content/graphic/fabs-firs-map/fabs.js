/*jslint browser: true, devel: true */
var vis;
(function () {
    "use strict";
    vis = {};
    var width, height,
        chart, svg, g, active, background,
        path,
        defs, style,
        slider, step, maxStep, running, sv, timer,
        button;



    // general design from
    // http://www.jeromecukier.net/blog/2013/11/20/getting-beyond-hello-world-with-d3/
    vis.init = function (params) {
        vis.params = params || {};

        chart = d3.select(vis.params.chart || "#chart"); // placeholder div for svg
        width = vis.params.width || 960;
        height = vis.params.height || 500;
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


        g = svg.selectAll("g.all")
            .data([{}]).enter()
            .append("g")
            .classed("all", true);

        // vis.init can be re-ran to pass different height/width values
        // to the svg. this doesn't create new svg elements.

        style = svg.selectAll("style")
            .data([{}]).enter()
            .append("style")
            .attr("type", "text/css");
        // this is where we can insert style that will affect the svg directly.

        defs = svg.selectAll("defs").data([{}]).enter()
            .append("defs");
        // this is used if it's necessary to define gradients, patterns etc.

        // the following will implement interaction around a slider and a
        // button. repeat/remove as needed.
        // note that this code won't cause errors if the corresponding elements
        // do not exist in the HTML.
        slider = d3.select(vis.params.slider || ".slider");

        if (slider[0][0]) {
            maxStep = slider.property("max");
            step = slider.property("value");
            slider.on("change", function () {
                vis.stop();
                step = this.value;
                vis.draw(vis.params);
            });
            running = vis.params.running || 0; // autorunning off or manually set on
        } else {
            running = -1; // never attempt auto-running
        }
        button = d3.select(vis.params.button || ".button");
        if (button[0][0] && running > -1) {
            button.on("click", function () {
                if (running) {
                    vis.stop();
                } else {
                    vis.start();
                }
            });
        }

        vis.loaddata(vis.params);
    };

    function ready(error, firs, world) {
        if (error) {
            console.error(error);
        }

        vis.firs = firs;
        vis.world = world;
        if (running > 0) {
            vis.start();
        } else {
            vis.draw(vis.params);
        }
    }

    vis.loaddata = function (params) {
        if (!params) { params = {}; }

        // if `params.refresh` is set/true forces the browser to reload the file
        // and not use the cached version due to URL being different (but the filename is the same)
        var topo = (params.topo || "ectrl-firs.json") + (params.refresh ? ("#" + Math.random()) : "");
        var world = (params.world || "world-50m.json") + (params.refresh ? ("#" + Math.random()) : "");

        queue()
            .defer(d3.json, topo)
            .defer(d3.json, world)
            .await(ready);
    };

    vis.play = function () {
        if (i === maxStep && !running) {
            step = -1;
            vis.stop();
        }

        if (i < maxStep) {
            step = step + 1;
            running = 1;
            d3.select(".stop").html("Pause").on("click", vis.stop(params));
            slider.property("value", sv);
            vis.draw(params);
        } else {
            vis.stop();
        }
    };

    vis.start = function (params) {
        timer = setInterval(function () { vis.play(params); }, 50);
    };

    vis.stop = function (params) {
        clearInterval(timer);
        running = 0;
        d3.select(".stop").html("Play").on("click", vis.start(params));
    };

    var zoom = d3.behavior.zoom()
            .scaleExtent([1, 8000])
            .on("zoom", zoomed);

    function zoomed() {
        g.style("stroke-width", 1.5 / d3.event.scale + "px");
        g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    }

    // If the drag behavior prevents the default click,
    // also stop propagation so we don’t click-to-zoom.
    function stopped() {
        if (d3.event.defaultPrevented) d3.event.stopPropagation();
    }

    function reset() {
        active.classed("active", false);
        active = d3.select(null);
        svg.transition()
            .duration(750)
            .call(zoom.translate([0, 0]).scale(1).event);
    }

    function clicked(d) {
        if (active.node() === this) {
            return reset();
        }
        active.classed("active", false);
        active = d3.select(this).classed("active", true);

        var bounds = path.bounds(d),
            dx = bounds[1][0] - bounds[0][0],
            dy = bounds[1][1] - bounds[0][1],
            x = (bounds[0][0] + bounds[1][0]) / 2,
            y = (bounds[0][1] + bounds[1][1]) / 2,
            scale = .9 / Math.max(dx / width, dy / height),
            translate = [width / 2 - scale * x, height / 2 - scale * y];

        svg.transition()
            .duration(750)
            .call(zoom.translate(translate).scale(scale).event);
    }

    vis.draw = function (params) {
        // make stuff here!
        var pars = params || {},
            scale = pars.scale || 530,
		      	cLon = pars.rotateLon || 0,
    		  	cLat = pars.rotateLan || -53,
            projection = d3.geo.azimuthalEqualArea()
                .scale(scale)
                .translate([width / 2, height / 2])
                .rotate([0,-53])
                .clipAngle(180 - 1e-3)
                .precision(1),
            // projection = d3.geo.albers()
            //     .center([cLon, cLat])
            //     .rotate([4.4, 0])
            //     .parallels([34, 70])
            //     .scale(scale)
            //     .translate([width / 2, height / 2]),
            firs = topojson.feature(vis.firs, vis.firs.objects.firs).features,

            tooltip = d3.select("#tooltip").classed("hidden", true),
            infotext = tooltip.select("#info"),
            graticule = d3.geo.graticule(),

            land = topojson.feature(vis.world, vis.world.objects.land),
            countries = topojson.feature(vis.world, vis.world.objects.countries).features,
            borders = topojson.mesh(vis.world, vis.world.objects.countries, function (a, b) { return a.id !== b.id; }),
            country, fir,
            fabs = [{"id": "BALTICFAB", "name": "Baltic FAB"},
                    {"id": "BLUMEDFAB", "name": "Blue Med FAB"},
                    {"id": "DANUBEFAB", "name": "Danube FAB"},
                    {"id": "DKSEFAB", "name": "Denmark-Sweden FAB"},
                    {"id": "FABCE", "name": "FAB Central Europe (SES RP2)"},
                    {"id": "FABEC", "name": "FAB Europe Central"},
                    {"id": "NEFAB", "name": "North European FAB"},
                    {"id": "SWFAB", "name": "South West FAB"},
                    {"id": "UKIRELANDFAB", "name": "UK-Ireland FAB"}
                   ];

        path = d3.geo.path()
            .projection(projection);

        svg.on("click", stopped, true);
        background.on("click", reset);
        g.style("stroke-width", "0.5px");

        svg
//            .call(zoom) // delete this line to disable free zooming
            .call(zoom.event);

        svg.on("mousemove", function () {
            // update tooltip position
            tooltip.style("top", (d3.event.pageY + 16) + "px").style("left", (d3.event.pageX + 10) + "px");
            return true;
        });


        svg.selectAll(".path.graticule")
            .data([graticule]).enter()
            .append("path")
            .classed("graticule", true)
            .attr("d", path);


        country = g.selectAll(".country")
            .data(countries)
            .enter().insert("path", ".graticule")
            .attr("class", function (d) {return "country country" + d.id; })
            .attr("d", path)
            .text(function (d) { return d.id; });

        //  FIRs
        fir = g.selectAll(".fir")
            .data(firs)
            .enter().insert("path", ".graticule")
            .attr("class", function (d) { return "fir " + d.id; })
            .attr("d", path)
            .on("click", clicked)
            .on("mouseover", function (d) {
                d3.select(this).style("fill", "red");
                tooltip.classed("hidden", false);
                infotext.text(d.id + "; " + d.properties.name);
            })
            .on("mouseleave", function () {
                d3.select(this).style("fill", "yellow");
                tooltip.classed("hidden", true);
            });

        // intra FIR borders
        g.selectAll(".fir-boundary")
            .data([topojson.mesh(vis.firs, vis.firs.objects.firs, function (a, b) {
                return a !== b;
            })])
            .enter().insert("path", ".graticule")
            .attr("d", path)
            .attr("class", "fir-boundary");

        // external borders
        g.selectAll("fir-boundary ECTRL")
            .data([topojson.mesh(vis.firs, vis.firs.objects.firs, function (a, b) {
                return a === b;
            })])
            .enter().insert("path", ".graticule")
            .attr("d", path)
            .attr("class", "fir-boundary ECTRL");

        // TODO: this seems not too much a D3 idiom...
        fabs.forEach(function (f) {
      	    // from http://stackoverflow.com/a/16093597/963575
            var fff = [];
      	    var mmm = topojson.merge(
    			      vis.firs,
    			      vis.firs.objects.firs.geometries.filter(function (d) {
                    if (d.properties.fab === f.id) {
                        fff.push(d.id);
                        return true;
                    }
      			        return false;
    		        }));
            mmm.id = f.id;
            mmm.name = f.name;
            mmm.firs = fff;
  			    g.append('path')
    			      .datum(mmm)
    			      .attr('class', 'fab ' + f.id)
    			      .attr('d', path)
                .on("click", clicked)
                .on("mouseover", function (d) {
                    d3.select(this).style("fill", "red");
                    tooltip.classed("hidden", false);
                    infotext.html("<p>" + d.name + "</p>"); // TODO: include additional info
                })
                .on("mouseleave", function () {
                    d3.select(this).style("fill", "blue");
                    tooltip.classed("hidden", true);
                });
        });

    };

}());
