var http = require('http');
var url = require('url');

function log (object) {
	console.log('[' + (new Date()).toISOString() + '] ' + JSON.stringify(object));
};

function exitWithError (code) {
	var exitCodes = {
		'EADDRINUSE': -110,
	};
	process.exit(exitCodes[code] || -100);
};

function start () {
	var host = process.env.OPENSHIFT_PERL_IP || 'localhost';
	var port = process.env.OPENSHIFT_PERL_PORT || 8080;

	http.createServer(function(request, response) {
		var uri = url.parse(request.url, true);
		var action = uri.pathname;

		if (action == '/status') {
			sendResponse(response, { s: 'ok' });
		} else {
			sendResponse(response, { s: 'error', errmsg: 'Unknown request: ' + action + '.' });
		}
	}).listen(port, host, function() {
		log('LISTENING: http://' + host + ':' + port);
	}).on('error', function(e) {
		if (e.code == 'EADDRINUSE') {
			log('ERROR: address in use: http://' + host + ':' + port);
			exitWithError(e.code);
		}
	});
};

function sendResponse (response, data) {
	var defaultResponseHeader = {
		'Content-Type': 'text/plain',
		'Access-Control-Allow-Origin': '*'
	};

	var str = JSON.stringify(data);
	if (str.length > 500) {
		var part = 100;
		var begin = str.substring(0, part - 1);
		var end = str.substring(str.length - 1 - part, str.length - 1);
		log('OUTGOING: \'' + begin + ' <...> ' + end + '\'.');
	} else {
		log('OUTGOING: \'' + str + '\'.');
	}

	response.writeHead(200, defaultResponseHeader);
	response.write(str);
	response.end();
};

start();
