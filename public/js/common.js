

$(document).ready(function(){
	//Hide table headers until results are gathered. 
	$('#results-table').hide();



	$('#bounceback-search').click(function(e,o){
		//Prevent submit action
		e.preventDefault();
		

		//capture all variables from text boxes
		var dist_id = $('#dist_id').val();
		var start_date = $('#start_datetime').val() + ':00';
		//start_date = date_time_splitter(start_date);
		var end_date = $('#end_datetime').val() + ':00';
		//end_date = date_time_splitter(end_date);


		var url = extract_base_url() + "/bounceback/"+ dist_id + "/" + start_date + "/" + end_date
		$.ajax({
			type: "GET",
			url: url, 
			beforeSend: function(){
				$('#bounce_back_table_loader').show();
				$('#bounceback-search').attr('disabled', true);
				$('#results_table').empty();
				

			},
			success: function(results){
				$('#results_table').show();
				if (results) {
					results = JSON.parse(results);
					$('#results_table').append('<tr><th>#</th><th>Message</th></tr>')
					drawTable(results.messages);
				}
				else {
					alert('No data returned');
				}
				
			},
			error: function(results){
				console.log(results);
				alert('Something went wrong with returned status of: ' + results.status 
					+ '\n Check if you are on the right network or connected to VPN' 
					+ '\n Make sure your search criteria is correcct');
			},
			complete: function(){
				$('#bounce_back_table_loader').hide();
				$('#bounceback-search').attr('disabled', false)
			}

		});

		
	});
});

function drawTable(results) {
    for (var i = 0; i < results.length; i++) {
        drawRow(results[i], i);
    }
};

function drawRow(rowData, index) {
    var row = $("<tr />")
    $("#results_table").append(row); 
    row.append($("<td>" + index + "</td>"));
    row.append($("<td>" + rowData + "</td>"));
};

function extract_base_url(){
	pathArray = location.href.split( '/' );
	protocol = pathArray[0];
	host = pathArray[2];
	url = protocol + '//' + host;
	return url
};


