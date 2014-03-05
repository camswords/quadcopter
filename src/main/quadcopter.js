var throttle = 0;

setWatch(function(event) {
  var inputValue = Math.floor(((event.time - event.lastTime) * 100000) - 100);

  if (inputValue > 100) {
    throttle = 100;
  } else if (inputValue < 0 || isNaN(inputValue)) {
    throttle = 0;
  } else {
    throttle = inputValue;
  }
}, A13, { repeat: true, edge: 'falling' });


var interval = setInterval(function() {
  digitalPulse(C9, 1, 1 + E.clip(throttle / 100, 0, 1));
  digitalPulse(C8, 1, 1 + E.clip(throttle / 100, 0, 1));
  digitalPulse(C7, 1, 1 + E.clip(throttle / 100, 0, 1));
  digitalPulse(C6, 1, 1 + E.clip(throttle / 100, 0, 1));
}, 50);

save();
