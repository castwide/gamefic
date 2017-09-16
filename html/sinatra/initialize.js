Gamefic.onStart(function() {
	$.post('/start', function(response) {
		Gamefic.update(response);
	});
	return null;
});

Gamefic.onReceive(function(input) {
	$.post('/update', {command: input}, function(response) {
		Gamefic.update(response);
	}).fail(function(response) {
		console.log('An error occurred');
		console.log(JSON.stringify(response));
	});
});

Gamefic.onRestore(function(json) {
	console.warn('Sinatra restore is not implented.');
	return null;
});
