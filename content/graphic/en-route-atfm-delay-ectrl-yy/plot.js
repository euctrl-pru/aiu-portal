(function () {
  var width = 700;
  var height = 0.618 * width; // golden ratio

  var svg = d3.select('svg')
        .attr("width", width)
        .attr("height", height);
  var margin = {top: 20, right: 100, bottom: 30, left: 40};
  var plot_width = width - margin.left - margin.right;
  var plot_height = height - margin.top - margin.bottom;
  var g = svg.append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  var codes = ["c", "s", "i", "g", "n", "p", "w"];
  var labels = ["capacity - ATC",
                "staffing - ATC",
                "disruption - ATC",
                "capacity - non ATC",
                "disruption - non ATC",
                "event - non ATC",
                "weather"];

  svg.append('circle').attr('id', 'tipfollowscursor');

  var tip = d3.tip()
        .attr('class', 'd3-tip')
        .offset([-15, 5])
       .html(function(d) {
//         var msg = labels.reverse()[codes.indexOf(d.key)];
//         return "<strong>" + msg +": </strong><span style='color:red'>" +
         return "<span>" +
           d.p.data[d.key] + "</span>";
       })
  ;
  svg.call(tip);

  var x = d3.scaleBand()
        .rangeRound([0, plot_width])
        .padding(0.1)
        .align(0.1);

  var y = d3.scaleLinear()
        .rangeRound([plot_height, 0]);

  // TODO: use colorbrewer!
  var colors = ['#C0504D',
                '#D99694',
                '#E6B9B8',
                '#558ED5',
                '#B9CDE5',
                '#DCE6F2',
                '#C3D69B'];
  var z = d3.scaleOrdinal()
        .range(colors);

  // gridlines in y axis function
  function make_y_gridlines() {
    return d3.axisLeft(y)
      .ticks(5);
  }

  var stack = d3.stack();

  d3.csv("ert_dly_ectrl_yy.csv", type, function(error, data) {
    if (error) throw error;


    x.domain(data.map(function(d) { return d.year; }));
    y.domain([0, d3.max(data, function(d) { return d.total; })]).nice();
    z.domain(data.columns.slice(2));

    var s = d3.formatSpecifier("f");
    s.precision = d3.precisionFixed(0.01);
    var formatter = d3.format(s);

    var cols = data.columns.slice(2);
    var dataset = stack.keys(cols)(data);

    g.selectAll(".serie")
      .data(dataset)
      .enter().append("g")
      .attr("class", "serie")
      .attr("fill", function(d) { return z(d.key); })
      .selectAll("rect")
      .data(function(d) {
        // return all the data you need as flat as possible
        var rv = d.map(function(elem){
          return {p: elem, key: d.key};
        });
        return rv;
      })
      .enter().append("rect")
      .attr("x", function(d) {
        return x(d.p.data.year);
      })
      .attr("y", function(d) { return y(d.p[1]); })
      .attr("height", function(d) { return y(d.p[0]) - y(d.p[1]); })
      .attr("width", x.bandwidth())
      .on("mousemove", function(d) {
        var target = d3.select('#tipfollowscursor')
              .attr('cx', d3.event.offsetX - 2)
              .attr('cy', d3.event.offsetY - 3) // 5 pixels above the cursor
              .node();
        tip.show(d, target);
      })
      .on("mouseout", tip.hide);

    // add the Y gridlines
    g.append("g")
      .attr("class", "grid")
      .call(make_y_gridlines()
            .tickSize(-plot_width)
            .tickFormat("")
           );

    g.append("g")
      .attr("class", "axis axis--x")
      .attr("transform", "translate(0," + plot_height + ")")
      .call(d3.axisBottom(x));

    g.append("g")
      .attr("class", "axis axis--y")
      .call(d3.axisLeft(y).ticks(10, "s"))
      .append("text")
      .attr("x", 2)
      .attr("y", y(y.ticks(10).pop()))
      .attr("dy", "0.35em")
      .attr("text-anchor", "start")
      .attr("fill", "#000")
      .text("En-route ATFM Delays (min/flight)");



    var ordinal = d3.scaleOrdinal()
          .domain(cols.reverse())
          .range(colors.reverse());


    svg.append("g")
      .attr("class", "legendOrdinal")
      .attr("transform", "translate(" + (width - margin.right -65) + ",20)");

    var legendOrdinal = d3.legendColor()
          .labels(labels.reverse())
          .shapeWidth(15)
          .shapePadding(5)
          .scale(ordinal);

    svg.select(".legendOrdinal")
      .call(legendOrdinal);
  });

  // sum all the delays up
  function type(d, i, columns) {
    // start from 'c' (3rd col, hence i=2)
    for (i = 2, t = 0; i < columns.length; ++i) t += d[columns[i]] = +d[columns[i]];
    d.total = t;
    return d;
  }

})();
