require 'sinatra'

get '/' do
   haml :index 
end

get '/about' do
    "This is a test"
end