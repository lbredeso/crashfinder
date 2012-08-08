var Color = Color || {
  generate: function(maxCount) {
    var red = 255;
    var step = maxCount / 255;
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
        
        color: function() {
          // The color space has to be adjusted here to avoid things being too white
          if (maxCount > 255) {
            return 255 - Math.floor(min / step);
          } else {
            return 255 - Math.floor(255 * (min / maxCount));
          }
        }
      }
    }
    
    var offset = 0.00000001;
    for (var i = 0; i < 255; i++) {
      ranges.push(range(i * step + offset, (i + 1) * step));
    }
    
    return {
      toHex: function(value) {
        for (var r in ranges) {
          if (ranges[r].encapsulates(value)) {
            var color = ranges[r].color();
            return ((1 << 24) + (red << 16) + (color << 8) + color).toString(16).slice(1);
          }
        }
      }
    }
  }
};