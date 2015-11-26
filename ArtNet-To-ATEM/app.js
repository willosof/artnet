var debug = require("debug")("main");
var ATEM = require('applest-atem');
var atem = new ATEM();
var artnetsrv = require('artnet-node/lib/artnet_server.js');
var dialog = require('dialog');

var atemIP = "10.20.30.101";
var dmxChannel = 1;
var dmxUniverse = 1;
var dmxPhysical = 1;
var debugArtnet = 1;

var connected = 0;
var lastOut1 = 0;
var lastOut2 = 0;
var lastOut3 = 0;

dmxChannel--;

debug("Starting artnet2atem");

debug("atemConnect", "Connecting to ATEM");
atem.connect('10.20.30.101'); 

atem.on('connect', function() {
	debug("atemConnect", "ATEM Connected");
	connected = 1;
});

var srv = artnetsrv.listen(6454, function(msg, peer) {
	if (debugArtnet) {
		debug("artnet", msg);
	}

	if (msg.universe == dmxUniverse && msg.physical == dmxPhysical && connected) {
		if (lastOut1 != msg.data[0]) {
			lastOut1 = msg.data[dmxChannel+0];
			atem.changeProgramInput(msg.data[dmxChannel+0]);
			//atem.changePreviewInput(msg.data[dmxChannel+0]);
			//atem.autoTransition();
		}
	}

	if (msg.universe == dmxUniverse && msg.physical == dmxPhysical && connected) {
		if (lastOut2 != msg.data[dmxChannel+1]) {
			lastOut2 = msg.data[dmxChannel+1];
			atem.changeProgramInput(msg.data[dmxChannel+1]);
		}
	}

	if (msg.universe == dmxUniverse && msg.physical == dmxPhysical && connected) {
		if (lastOut3 != msg.data[dmxChannel+2]) {
			lastOut3 = msg.data[dmxChannel+2];
			atem.changeProgramInput(msg.data[dmxChannel+2]);
		}
	}





});

atem.on('stateChanged', function(err, state) { var connected = 0; });

atem.on('stateChanged', function(err, state) {
  debug("stateChanged", state); // catch the ATEM state.
});
