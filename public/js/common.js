

$(document).ready(function(){
	$('#bounceback-search').click(function(e,o){
		//Prevent submit action
		e.preventDefault();
		$('#bounceback-search').attr('disabled', true)
		//capture all variables from text boxes
		var dist_id = $('#dist_id').val();
		var start_date = $('#start_datetime').val() + ':00';
		//start_date = date_time_splitter(start_date);
		var end_date = $('#end_datetime').val() + ':00';
		//end_date = date_time_splitter(end_date);
		console.log(dist_id);
		console.log(start_date);
		console.log(end_date);
		var url = "http://127.0.0.1:9393/bounceback/"+ dist_id + "/" + start_date + "/" + end_date
		$.ajax({
			type: "GET",
			url: url, 
			success: function(results){
				function drawTable(results) {
				    for (var i = 0; i < results.length; i++) {
				        drawRow(results[i]);
				    }
				}

				function drawRow(rowData) {
				    var row = $("<tr />")
				    $("#results_table").append(row); //this will append tr element to table... keep its reference for a while since we will add cels into it
				    row.append($("<td>" + rowData.id + "</td>"));
				    row.append($("<td>" + rowData.firstName + "</td>"));
				    row.append($("<td>" + rowData.lastName + "</td>"));
				}
				$('#bounceback-search').attr('disabled', false)
			},
			error: function(results){
				alert('Something went wrong');
				$('#bounceback-search').attr('disabled', false)
			}

		});

		
	});
});


// function date_time_splitter(date_time){
// 	//Comes through in form YYYY-MM-DDT00:00
// 	var split = date_time.split('T');
// 	var date = split[0];
// 	var time = split[1];
// 	//comes through in form YYYY-MM-DD
// 	var split_date = date.split('-');
// 	//convert to MM-DD-YYYY
// 	var new_date = split_date[1] + split_date[2] + split_date[0]
// 	return new_date + ' ' + time
// };