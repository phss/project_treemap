require 'sinatra'


get '/map' do
  erb :map
end

get '/release_d3.json' do
  File.read('release_d3.json') 
end
