(function () {

    var tags = [
        {"key": "Transparency", "value": 36}, // from https://t.co/HDWuIi1Y4z
        {"key": "ANS", "value": 15},
        {"key": "Truth", "value": 18},
        {"key": "Facts", "value": 25},
        {"key": "Objectivity", "value": 25},  // from https://t.co/HDWuIi1Y4z
        {"key": "Correct", "value": 15},
        {"key": "Up-to-date", "value": 25},
        {"key": "Consistency", "value": 22},
        {"key": "Performance", "value": 16},
        {"key": "Independence", "value": 36},
        {"key": "Standards", "value": 18},
        {"key": "Metrics", "value": 23},
        {"key": "Open", "value": 25},
        {"key": "ATM", "value": 18},
        {"key": "Europe", "value": 26}
    ].map(function(d) { return {"key": d.key.toLowerCase(), "value": d.value}; });

    var fill = d3.scale.category20b();

    // var w = window.innerWidth,
    //     h = window.innerHeight;
    var w = 350,
        h = 250;

    var max,
        fontSize;

    var layout = d3.layout.cloud()
            .timeInterval(Infinity)
            .size([w, h])
            .fontSize(function(d) {
                return fontSize(+d.value);
            })
            .text(function(d) {
                return d.key;
            })
            .on("end", draw);

    var svg = d3.select("#cloud").append("svg")
            .attr("width", w)
            .attr("height", h);

    var vis = svg.append("g")
            .attr("transform", "translate(" + [w >> 1, h >> 1] + ")");

    update();

    window.onresize = function(event) {
        update();
    };

    function draw(data, bounds) {
        svg.attr("width", w).attr("height", h);

        scale = bounds ? Math.min(
            w / Math.abs(bounds[1].x - w / 2),
            w / Math.abs(bounds[0].x - w / 2),
            h / Math.abs(bounds[1].y - h / 2),
            h / Math.abs(bounds[0].y - h / 2)) / 2 : 1;

        var text = vis.selectAll("text")
                .data(data, function(d) {
                    return d.text.toLowerCase();
                });
        text.transition()
            .duration(1000)
            .attr("transform", function(d) {
                return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
            })
            .style("font-size", function(d) {
                return d.size + "px";
            });
        text.enter().append("text")
            .attr("text-anchor", "middle")
            .attr("transform", function(d) {
                return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
            })
            .style("font-size", function(d) {
                return d.size + "px";
            })
            .style("opacity", 1e-6)
            .transition()
            .duration(1000)
            .style("opacity", 1);
        text.style("font-family", function(d) {
            return d.font;
        })
            .style("fill", function(d) {
                return fill(d.text.toLowerCase());
            })
            .text(function(d) {
                return d.text;
            });

        vis.transition().attr("transform", "translate(" + [w >> 1, h >> 1] + ")scale(" + scale + ")");
    }

    function update() {
        layout.font('impact').spiral('archimedean');
        fontSize = d3.scale['sqrt']().range([10, 100]);
        if (tags.length){
            fontSize.domain([+tags[tags.length - 1].value || 1, +tags[0].value]);
        }
        layout.stop().words(tags).start();
    }
}());
