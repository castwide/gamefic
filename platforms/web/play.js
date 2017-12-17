$(function() {
	$('#gamefic_controls form').submit(function(event) {
		$('#gamefic_controls').addClass('working');
		event.preventDefault();
		Gamefic.receive($('#gamefic_command').val());
		$('#gamefic_command').val('');
		$('#gamefic_controls').removeClass('working');
	});

	Gamefic.onStart((state) => {
		$('#gamefic_output').append(state['output']);
	});

	Gamefic.onUpdate((state) => {
		$('#gamefic_output').append(state['output']);
		if (state.scene == 'Conclusion') {
			$('#gamefic_console').addClass('concluded');
		}
	});

	Gamefic.start();
	$('#gamefic_controls').removeClass('working');
});
