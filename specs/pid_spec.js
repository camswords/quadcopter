var Pid = require('./pid');

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
