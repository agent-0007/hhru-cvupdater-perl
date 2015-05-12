$(function () {
	var user = $('a.navbar-link').text();
	$('#main').bootstrapTable({}).on('load-success.bs.table', function (e, name, args) {
		$(".update-switch").bootstrapSwitch({
			onSwitchChange: function(event, state) {
				$.ajax({
        			type: "GET",
        			url: 'switch?id='+ $(event.target).attr('id') +'&arg='+ state +'&user=' + user
        		});
        		setTimeout(function(){ $('#main').bootstrapTable('refresh', {silent: true}); }, 1000);
      		}
		});
	});
});

function willupdateFormatter(value, row) {
	if (value == 0)
		return '<input type="checkbox" class="update-switch" id="' + row.id + '">';
	else
		return '<input type="checkbox" class="update-switch" id="' + row.id + '" checked>';
}