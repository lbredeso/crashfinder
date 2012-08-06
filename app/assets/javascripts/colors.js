var Color = Color || {
  generate: function(maxCount) {
    var red = 255;
    var step = Math.floor(maxCount / 255);
    var ranges = [];
    var range = function(min, max) {
      return {
        encapsulates: function(value) {
          if (min <= value && max >= value) {
            return true;
          } else {
            return false;
          }
        },
        
        green: function() {
          // The color space has to be adjusted here to avoid things being too white
          return 175 - (max / step);
        },
        
        blue: function() {
          // The color space has to be adjusted here to avoid things being too white
          return 175 - (max / step);
        }
      }
    }
    
    for (var i = 1; i <= maxCount; i += step + 1) {
      ranges.push(range(i, i + step));
    }
    
    return {
      toHex: function(value) {
        for (var r in ranges) {
          var something = ranges;
          if (ranges[r].encapsulates(value)) {
            var rgb = ranges[r].blue() | (ranges[r].green() << 8) | (red << 16);
            return rgb.toString(16);
          }
        }
      }
    }
  }
};