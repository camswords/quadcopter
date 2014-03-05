
var SerialPort = require('serialport').SerialPort;
var Q = require('q');

var serialPort = new SerialPort('/dev/tty.usbmodem1421', { baudrate: 9600 }, false);
var uploaded = Q.defer();

serialPort.open(function() {
  setTimeout(function() {
    serialPort.write('echo(0);\n reset(); digitalWrite(LED1, true); echo(1);\n', function(err) {
      if (err) {
        uploaded.reject(err);
      } else {
        serialPort.drain(function() { uploaded.resolve(); });
      }
    });
  }, 5000);
});

uploaded.promise.then(function() {
  serialPort.close(function() {
    console.log('deploy successful.');
  });
}, function(err) {
  console.log('failed to deploy due to ', err);
  serialPort.close();
});


var waitForDeployToFinish = function() {
  setTimeout(function() {
    if (uploaded.promise.isPending()) {
      process.stdout.write('.');
      waitForDeployToFinish();
    }
  }, 1000);
};

waitForDeployToFinish();
