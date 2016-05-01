$(function() {
	$('#gamefic_controls form').submit(function(event) {
		event.preventDefault();
		Gamefic.update($('#gamefic_command').val());
	});
	Gamefic.onStart(function(response) {
		$('#gamefic_prompt').html(response.prompt);
	});
	Gamefic.onInput(function(response) {
		$('#gamefic_controls').addClass('working');
	});
	Gamefic.onFinish(function(response) {
		if (!response.testing) {
			$('#gamefic_controls').removeClass('working');
		}
		$('#gamefic_command').val('');
		$('#gamefic_command').focus();
		window.scrollTo(0, document.body.scrollHeight);
	});
	Gamefic.handleResponse('Active', function(response) {
		if (response.input != null) {
			$('#gamefic_output').append('<p><kbd>' + response.prompt + ' ' + response.input + '</kbd></p>');
		}
		$('#gamefic_output').append(response.output);
	});
	Gamefic.handleResponse('Conclusion', function(response) {
		if (response.input != null) {
			$('#gamefic_output').append('<p><kbd>' + response.prompt + ' ' + response.input + '</kbd></p>');
		}
		$('#gamefic_console').addClass('concluded');
		$('#gamefic_output').append(response.output);
		$('#gamefic_controls').hide();
	});
	Gamefic.start();
	$('#gamefic_command').focus();
});
