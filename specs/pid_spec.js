
var Pid = {
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




describe("corrective function", function() {
  it("should return the current error when past errors and delta are 0", function() {
    var step = Pid.create(1, 0, 0, 1000);
    expect(step(900)).toBe(100);
  });

  it("should return the sum of past errors when current and delta are 0", function() {
    var step = Pid.create (0, 1, 0, 1000);
    expect(step(900)).toBe(100);
    expect(step(900)).toBe(200);
  });

  it("should return the delta error when current and past errors are 0", function() {
    var step = Pid.create (0, 0, 1, 1000);
    expect(step(900)).toBe(100);
    expect(step(900)).toBe(0);
  });
});
