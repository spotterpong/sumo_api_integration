require 'sinatra'
require 'date'
require 'dotenv'
require 'faraday'
require 'faraday_middleware'
require 'json'
require 'multi_json'


before do
  headers "Content-Type" => "text/html; charset=utf-8"
end
def boucneBackCall(dist_id, startdate, enddate)

	# Load in credentials
	Dotenv.load
	email = ["SUMMOLOGIC_EMAIL"]
	password = ["SUMOLOGIC_PASSWORD"]

	# Initialize Faraday session
	headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}
	session = Faraday.new(url: 'https://api.sumologic.com/api/v1', headers: headers) do |connection|
	  connection.basic_auth(email, password)
	  connection.request  :json
	  connection.response :json, content_type: 'application/json'
	  connection.adapter  Faraday.default_adapter
	end


	# Make the API Request
	puts "Making API Request..."
	input_query = dist_id + " _index=mail"

	params = {q: input_query, from: startdate + '+00:00', to: enddate +'+00:00', tz: 'UTC'}
		puts startdate
	puts enddate
	r = session.get do |req|
	  req.url 'logs/search'
	  req.params = params
	end
	puts "\tDone!"


	# Grab the interesting information from each item returned
	puts "Parsing response..."
	if r.body
		puts r.body
		r.body.each do |i|
		  raw_message = JSON.parse(i["_raw"])

		  fields = raw_message["fields"] unless raw_message.nil?
		  log_level = fields["level"] unless fields.nil?

		  unless log_level.nil?
		    if log_level.downcase == "info" && fields["method"].downcase == "logbouncedemail"
		      message_json = '{' + raw_message["message"].split('{')[1]
		      message_json = message_json.split('}')[0] + '}'
		      message_json_2 = JSON.parse(message_json)

		      puts "\n\n"
		      puts message_json_2["Diagnostic-Code"].gsub('x-postfix; ', '')
		      puts "\n\n"

		      puts "\tDone!"
		      return message_json_2
		    end
		  end
		end
	else
		puts 'no results'
		puts "\tDone!"
	end

end


get '/' do
	@title = 'Bounceback API'
	haml :index 
end

get '/bounceback/:emd/:startdate/:enddate' do 
	dist_id = params[:emd]
	startdate = params[:startdate]
	enddate = params[:enddate]

	messages = boucneBackCall(dist_id, startdate, enddate)
	return messages
end