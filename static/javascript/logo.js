(function() {
  var dotSide = 4,
  dotSep   = 1,
  logoXPadding = 2 * dotSide,
  logoYPadding = 2 * dotSide,
  width = 11 * dotSide + 2 * logoXPadding,
  height = 5 * dotSide + 2 * logoYPadding,
  h = Math.floor(logoXPadding / 2) - 0.5 * dotSide,
  v = Math.floor(height - logoYPadding / 2) - 0.5 * dotSide;

  // console.log("width=" + width);
  // console.log("height=" + height);

  var nodes = [
    [ 3,  3, 0], // dots for 'P' (ordered like in handwriting ;-)
    [ 3,  5, 0],
    [ 3,  7, 0],
    [ 3,  9, 0],
    [ 3, 11, 0],
    [ 5, 11, 0],
    [ 7, 10, 0],
    [ 7,  8, 0],
    [ 5,  7, 0],
    [11,  3, 1], // dots for 'R' (first 9 like for 'P')
    [11,  5, 1],
    [11,  7, 1],
    [11,  9, 1],
    [11, 11, 1],
    [13, 11, 1],
    [15, 10, 1],
    [15,  8, 1],
    [13,  7, 1],
    [14,  5, 1], // 'R' leg
    [15,  3, 1],
    [19, 11, 2], // dots for 'U' (ordered like in handwriting ;-)
    [19,  9, 2],
    [19,  7, 2],
    [20,  5, 2],
    [21,  3, 2],
    [23,  3, 2],
    [23,  5, 2],
    [23,  7, 2],
    [23,  9, 2],
    [23, 11, 2]
  ],
  n = nodes.length,
  letters = ["p", "r", "u"];

  var svg = d3.select("#logo").append("svg")
              .attr("width", width)
              .attr("height", height);

  var g = svg.append("g")
              .attr("transform", "translate(" + h + "," + v + ")")

  g.selectAll("rect")
    .data(nodes)
    .enter().append("rect")
      .attr("class", function(d){ return "logo-" + letters[d[2]]})
      .attr("x", function(d) {
        return d.x = Math.round(d[0]/2 * dotSide);
      })
      .attr("y", function(d) {
        return d.y = Math.round(-d[1]/2 * dotSide);
      })
      .attr("width", dotSide - dotSep)
      .attr("height", dotSide - dotSep);


  var particles = nodes.slice();
  particles.push.apply(particles, particles.map(function(e){
    return {
      x: e.x,
      y: e.y,
      fixed: !0,
      radius: 0
    };
  }));

  particles.unshift({x: 1e4, y: 1e4}); // insert root node
  var root = particles[0];
  root.radius = 0;
  root.fixed = true;

  var links = d3.range(n).map(function(d){
    return {
      source: d + 1,
      target: d + n + 1
    }
  })

  var force = d3.layout.force()
    .gravity(0)
    .charge(function(d, i) { return i ? 0 : -200; })
    .linkDistance(0.1)
    .links(links)
    .nodes(particles)
    .size([width, height]);

  force.start();

  force.on("tick", function(e){
    var q = d3.geom.quadtree(particles),
    i = 0,
    n = particles.length;

    while (++i < n) q.visit(collide(particles[i]));

    svg.selectAll("rect")
    .attr("x", function(d) { return Math.round(d.x); })
    .attr("y", function(d) { return Math.round(d.y); });
  });


  svg
    .on("mousemove", mausIn)
    .on("touchmove", mausIn)
    .on("mouseout", mausOut)
    .on("touchend", mausOut);

  function mausOut() {
    var p1 = d3.mouse(this);
    root.px = root.py = 1e4;
    force.resume();
  }

  function mausIn() {
    var p1 = d3.mouse(this);
    root.px = p1[0] - h;
    root.py = p1[1] - v;
    force.resume();
  }

  function collide(node) {
    var r = node.radius + 16,
    nx1 = node.x - r,
    nx2 = node.x + r,
    ny1 = node.y - r,
    ny2 = node.y + r;
    return function(quad, x1, y1, x2, y2) {
      if (quad.point && (quad.point !== node)) {
        var x = node.x - quad.point.x,
        y = node.y - quad.point.y,
        l = Math.sqrt(x * x + y * y),
        r = node.radius + quad.point.radius;
        if (l < r) {
          l = (l - r) / l * .5;
          node.x -= x *= l;
          node.y -= y *= l;
          quad.point.x += x;
          quad.point.y += y;
        }
      }
      return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
    };
  }
})();
