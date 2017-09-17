Gamefic.onStart(function() {
	return new Promise((resolve) => {
		$.post('/start', function(response) {
			resolve(response);
		});	
	});
});

Gamefic.onReceive(function(input) {
	$.post('/update', {command: input}, function(response) {
		Gamefic.update(response);
	}).fail(function(response) {
		console.log('An error occurred');
		console.log(JSON.stringify(response));
	});
});

Gamefic.onRestore(function(state) {
	return new Promise((resolve) => {
		$.post('/restore', {snapshot: JSON.stringify(state)}, function(response) {
			resolve(response);
		}).fail(function(response) {
			console.log('An error occurred during a restore.');
			console.log(JSON.stringify(response));
		});
	});
});
