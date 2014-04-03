var Pid = require('./specs/pid');

VELOCITY = 0.5;

var updateThrottles = function(sim, change) {
  var deltaThrottle = change * VELOCITY;
  sim.leftThrottle += deltaThrottle;
  sim.rightThrottle -= deltaThrottle;
}

var quad = function(sim) {
  var force = sim.leftThrottle - sim.rightThrottle;
  sim.pitch += force * VELOCITY;

  return sim;
}

var die = function(sim) {
  console.log(sim);
  throw "We're dead";
}

var main = function(angle, lt, rt, proportional, integral, differential) {
  var sim = {
    pitch: angle,
    leftThrottle: lt,
    rightThrottle: rt
  };

  var correct = Pid.create(proportional, integral, differential, 0);

  setInterval(function() {

    console.log('angle: ' + sim.pitch.toFixed(1) + ', left: ' + sim.leftThrottle.toFixed(1) + ', right: ' + sim.rightThrottle.toFixed(1));

    var correctPitchBy = correct(sim.pitch);
    updateThrottles(sim, correctPitchBy);

    quad(sim);

    if (sim.pitch == 0) {
      die(sim);
    }

    if (sim.pitch > 90 || sim.pitch < -90 || Math.abs(sim.pitch) < 0.1) {
      die(sim);
    }
  }, 200);
};

main(
  (process.argv[2] || 30) * 1,
  (process.argv[3] || 50) * 1,
  (process.argv[4] || 50) * 1,
  (process.argv[5] || 1) * 1,
  (process.argv[6] || 0.5) * 1,
  (process.argv[7] || 1) * 1
);
