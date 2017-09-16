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

Gamefic.onRestore(function(json) {
	return new Promise((resolve) => {
		var state = JSON.parse(json);
		$.post('/restore', {snapshot: json}, function(response) {
			response.output = '<p>Game restored to last available turn.</p>';
			resolve(response);
		});
	});
});
