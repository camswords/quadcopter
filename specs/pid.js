
module.exports = {
  create: function(proportional, integral, differential, target) {
    var cumulativeError = 0;
    var lastError = 0;

    return function (current) {
      var error = target - current;
      var diff = error - lastError;
      lastError = error;
      cumulativeError += error;

      return proportional * error +
        integral * cumulativeError +
        differential * diff;
    }
  }
};
