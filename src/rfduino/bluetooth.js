var noble = require('noble');

var recordMessage = (function() {
  var line = '';
  
  return function(linePart) {
    if (linePart.indexOf('|') != -1) {
      newLineIndex = linePart.indexOf('|') + 1;

      console.log(line + linePart.slice(0, newLineIndex));
      line = '';

      recordMessage(linePart.slice(newLineIndex));
    } else {
     line += linePart; 
    }  
  };
})();

noble.startScanning(['2220']);

noble.on('discover', function(peripheral) {
  if (peripheral.advertisement.localName == 'RFduino') {
    var connect = function() {
      peripheral.connect(function(error) {
        if (error) {
          console.log('failed to connect to the RFduino, error is ', error);
        }
      });
    };
    
    peripheral.on('disconnect', function() {
      console.log('disconnected, retrying...');
      setTimeout(function() { connect(); }, 100);
    });
    
    peripheral.on('connect', function() {
      peripheral.discoverServices(['2220']);
    });
     
    peripheral.on('servicesDiscover', function(services) {
      services[0].on('characteristicsDiscover', function(characteristics) {
        characteristics[0].on('read', function(data, isNotification) {
          recordMessage(data.toString());
        });

        console.log('requesting data...');
        characteristics[0].notify(true);
      });
      
      services[0].discoverCharacteristics(['2221']);
    });
    
    connect();
  }
});
