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
	email = ""
	password = ""
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
	if r.body.length > 0
		message_json_array = Array.new
		r.body.each do |i|
		  raw_message = JSON.parse(i["_raw"])

		  fields = raw_message["fields"] unless raw_message.nil?
		  log_level = fields["level"] unless fields.nil?

		  unless log_level.nil?
		    if log_level.downcase == "info" && fields["method"].downcase == "logbouncedemail"
		      # message_json = '{' + raw_message["message"].split('{')[0]
		      # message_json = message_json.split('}')[0] + '}'
		      message_json = raw_message["message"]
		      message_json_array.push(message_json)
		    end
		  end
		end
		message_json_json = {}
		message_json_json[:messages] = message_json_array
		message_json_json = JSON.generate(message_json_json)
		return message_json_json
	elsif r.body.length == 0
		status = "Nothing found - API gave a return of #{r.status}"
		puts status
		return status
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