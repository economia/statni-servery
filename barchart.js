var margin = {
    top: 10,
    right: 10,
    bottom: 10,
    left: 50
};

var w = 670 - margin.left - margin.right;
var h = 480 - margin.top - margin.bottom;

var svg = d3.select("body")
    .append("svg")
    .attr("width", w + margin.left + margin.right)
    .attr("height", h + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var popisky = [
    "Období",
    "Města",
    "Vysílací práva",
    "Globální reklamní partneři",
    "Partneři v hostitelských zemích",
    "Prodej vstupenek",
    "Poplatky za použití olympijských motivů",
    "Celkem"
];

/* load data */

d3.csv("../data/marketing-revenue.csv", function(dataset) {

    var yScale = d3.scale.linear()
            .domain([0, d3.max(dataset, function(d, i) {
                return d.celkem;
            })])
            .range([h, 0]);

    var xScale = d3.scale.ordinal()
            .domain(dataset.map(function(d) {return d.mesta}))
            .rangeRoundBands([0, w], 0.05);

    var yAxis = d3.svg.axis()
            .scale(yScale)
            .orient("left");

    /* insert elements */
    svg.selectAll("rect")
        .data(dataset)
        .enter()
        .append("rect")
        .attr("x", function(d, i) {
            return xScale(d.mesta);
        })
        .attr("width", xScale.rangeBand())
        .attr("y", function(d) {   
            return yScale(d.celkem);
        })
        .attr("height", function(d) {
            return h - yScale(d.celkem);
        })
        .attr("fill", "skyblue")
        .attr("stroke", "black")
        .attr("stroke-width", 1)

    svg.append("g")
        .attr("class", "axis")
        .call(yAxis);
});