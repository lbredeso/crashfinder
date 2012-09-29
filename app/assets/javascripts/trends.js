var Trends = function() {
  var txtattr = { font: "12px sans-serif" };
  var colors = [
    "#995555", // red
    "#555599", // blue
    "#6DC788", // light green
    "#9BD1E0"  // light blue
  ];
  
  return {
    yearly: function(locationIds) {
      var r = Raphael("yearly");
      
      $.ajax({
        url: "/trends/yearly",
        dataType: 'json',
        success: function(response) {
          var yearStats = response;
          var groupedYearStats = _.groupBy(yearStats, "locationId");
          
          // The location labels, for our legend
          var labels = _.map(groupedYearStats, function(yearStatGroup) {
            return _.first(yearStatGroup).label;
          });
          
          // Plot years along the x axis
          var xValues = _.map(groupedYearStats, function(yearStatGroup) {
            return _.map(yearStatGroup, function(yearStat) {
              return yearStat.year;
            });
          });
          
          // Plot crash count along the y axis
          var yValues = _.map(groupedYearStats, function(yearStatGroup) {
            return _.map(yearStatGroup, function(yearStat) {
              return yearStat.count;
            });
          });
          
          var chart = r.linechart(
            10, 10,      // top left anchor
            560, 250,    // bottom right anchor
            xValues,
            yValues,
            {
              nostroke: false,   // lines between points are drawn
              axis: "0 0 1 1",   // draw axes on the left and bottom
              smooth: true,      // curve the lines to smooth turns on the chart
              colors: _.first(colors, labels.length)
            }
          );
          
          chart.labels = r.set();
     	    var x = 15; var h = 5;
     	    for( var i = 0; i < labels.length; ++i ) {
     	      var clr = chart.lines[i].attr("stroke");
     	      chart.labels.push(r.set());
     	      chart.labels[i].push(r["circle"](x + 5, h, 5)
     	                           .attr({fill: clr, stroke: "none"}));
     	      chart.labels[i].push(txt = r.text(x + 20, h, labels[i])
     	                           .attr(txtattr)
     	                           .attr({fill: "#000", "text-anchor": "start"}));
     	      x += chart.labels[i].getBBox().width * 1.2;
     	    };
        }
      });
    },
    
    monthly: function(locationIds) {
      var r = Raphael("monthly");
      
      $.ajax({
        url: "/trends/monthly",
        dataType: 'json',
        success: function(response) {
          var yearStats = response;
          var groupedYearStats = _.groupBy(yearStats, "locationId");
          
          // The location labels, for our legend
          var labels = _.map(groupedYearStats, function(yearStatGroup) {
            return _.first(yearStatGroup).label;
          });
          
          // Plot years along the x axis
          var xValues = _.map(groupedYearStats, function(yearStatGroup) {
            return _.map(yearStatGroup, function(yearStat) {
              return yearStat.month;
            });
          });
          
          // Plot crash count along the y axis
          var yValues = _.map(groupedYearStats, function(yearStatGroup) {
            return _.map(yearStatGroup, function(yearStat) {
              return yearStat.count;
            });
          });
          
          var chart = r.linechart(
            10, 10,      // top left anchor
            560, 250,    // bottom right anchor
            xValues,
            yValues,
            {
              nostroke: false,   // lines between points are drawn
              axis: "0 0 1 1",   // draw axes on the left and bottom
              smooth: true,      // curve the lines to smooth turns on the chart
              colors: _.first(colors, labels.length)
            }
          );
          
          chart.labels = r.set();
     	    var x = 15; var h = 5;
     	    for( var i = 0; i < labels.length; ++i ) {
     	      var clr = chart.lines[i].attr("stroke");
     	      chart.labels.push(r.set());
     	      chart.labels[i].push(r["circle"](x + 5, h, 5)
     	                           .attr({fill: clr, stroke: "none"}));
     	      chart.labels[i].push(txt = r.text(x + 20, h, labels[i])
     	                           .attr(txtattr)
     	                           .attr({fill: "#000", "text-anchor": "start"}));
     	      x += chart.labels[i].getBBox().width * 1.2;
     	    };
        }
      });
    },
    
    daily: function(locationIds) {
      var r = Raphael("daily");
      
      $.ajax({
        url: "/trends/daily",
        dataType: 'json',
        success: function(response) {
          var yearStats = response;
          var groupedYearStats = _.groupBy(yearStats, "locationId");
          
          // The location labels, for our legend
          var labels = _.map(groupedYearStats, function(yearStatGroup) {
            return _.first(yearStatGroup).label;
          });
          
          // Plot years along the x axis
          var xValues = _.map(groupedYearStats, function(yearStatGroup) {
            return _.map(yearStatGroup, function(yearStat) {
              return yearStat.day;
            });
          });
          
          // Plot crash count along the y axis
          var yValues = _.map(groupedYearStats, function(yearStatGroup) {
            return _.map(yearStatGroup, function(yearStat) {
              return yearStat.count;
            });
          });
          
          var chart = r.linechart(
            10, 10,      // top left anchor
            560, 250,    // bottom right anchor
            xValues,
            yValues,
            {
              nostroke: false,   // lines between points are drawn
              axis: "0 0 1 1",   // draw axes on the left and bottom
              smooth: true,      // curve the lines to smooth turns on the chart
              colors: _.first(colors, labels.length)
            }
          );
          
          chart.labels = r.set();
     	    var x = 15; var h = 5;
     	    for( var i = 0; i < labels.length; ++i ) {
     	      var clr = chart.lines[i].attr("stroke");
     	      chart.labels.push(r.set());
     	      chart.labels[i].push(r["circle"](x + 5, h, 5)
     	                           .attr({fill: clr, stroke: "none"}));
     	      chart.labels[i].push(txt = r.text(x + 20, h, labels[i])
     	                           .attr(txtattr)
     	                           .attr({fill: "#000", "text-anchor": "start"}));
     	      x += chart.labels[i].getBBox().width * 1.2;
     	    };
        }
      });
    }
  };
};